# kilden-protos

Contratos de wire de Kilden. El `Envelope` (proto/events/v1) es el contrato
central de todo el pipeline: cualquier cambio acá afecta a todos los servicios.

No todo contrato de wire es protobuf: `messenger/` guarda los del chat
(fase 8b, ../docs/24) y `filters/` la gramática de filtros (fase 3 de
../docs/35), que son JSON y viven acá por la misma razón que los `.proto` —
es el repo neutral que consumen tanto kilden-core como kilden-panel sin que
ninguno dependa del otro.

```bash
make lint       # buf lint
make generate   # codegen Go (kilden-core) y PHP (kilden-panel) en gen/
make breaking   # bloquea cambios incompatibles contra main
```

## `messenger/` — contratos del chat (fase 8b)

| Archivo | Qué | Cómo se cambia |
|---|---|---|
| `frames.json` | El protocolo WS completo: frames en ambos sentidos, formas de las entidades, los malformados que hay que rechazar, códigos de error | A mano — **es** el contrato: el servidor se escribe para satisfacerlo, no al revés. Cambiarlo va junto con ../docs/24 en el mismo PR |
| `tickets.json` | Vectores congelados del ticket de agente (el panel firma, cmd/messenger verifica) | **Generado**, jamás a mano: `cd kilden-core && go run ./scripts/messengervectors -out ../kilden-protos/messenger` |

Los consumen los tests de kilden-core (`internal/messenger`) y de kilden-panel
(`tests/Feature/Messenger`), que los localizan con `KILDEN_PROTOS_DIR` (default:
el checkout hermano). Sin ese checkout los tests se saltan; en CI la variable
va fija, así que saltarse es imposible. Si un cambio de acá rompe a alguno de
los dos, esa es la señal: el contrato tiene dos implementaciones y ninguna
manda sobre la otra.

## `filters/` — gramática de filtros v2 (fase 3, ../docs/34 y ../docs/35)

Una condición de targeting es la misma idea en cuatro superficies (feature
flags, cohortes, trigger de campañas y branches), y hasta la fase 3 cada una
la escribía a su manera: tres evaluadores en Go, tres validadores en PHP y el
espejo TypeScript del builder. Nada los ataba, así que derivaron. El contrato
único vive acá.

| Archivo | Qué | Cómo se cambia |
|---|---|---|
| `schema.json` | JSON Schema (draft 2020-12) del AST: forma de grupos/condiciones y qué operadores admite cada tipo de dato | A mano, junto con ../docs/34 en el mismo PR |
| `vectors.json` | Los casos entrada→veredicto: `cases` (semántica normal), `defensive` (lo desconocido jamás matchea) y `legacy` (traducción v1→v2 que usa la migración del panel) | A mano — **es** el contrato |

Reglas que los vectores fijan y conviene no re-descubrir a los golpes:
ausencia nunca es un valor (`is_not` sobre una key ausente es `false`; solo
`is_set`/`is_not_set` hablan de presencia), `is`/`in` comparan exacto mientras
`contains`/`starts_with`/`ends_with` son case-insensitive (heredan el
`icontains` de v1, que compilaba a `ILIKE`), los lectores en memoria coercionan
el operando (los `person_properties` de `/decide` no pasan por el enricher), y
un operador/scope/tipo desconocido **nunca** matchea, tampoco por negación.

Los consume kilden-core (`internal/filters`) con el mismo `KILDEN_PROTOS_DIR`
que `messenger/`, y desde el release B de la fase 3 también kilden-panel.

Los `option go_package` apuntan a `github.com/freshworkstudio/kilden-protos`.
Mientras el módulo Go no esté publicado, los consumidores usan un `replace`
local apuntando a `../kilden-protos/gen/go` (el `go.mod` de ese directorio lo
escribe `make generate`).
