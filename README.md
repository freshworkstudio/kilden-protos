# kilden-protos

Contratos de wire de Kilden. El `Envelope` (proto/events/v1) es el contrato
central de todo el pipeline: cualquier cambio acá afecta a todos los servicios.

No todo contrato de wire es protobuf: `messenger/` guarda los del chat
(fase 8b, ../docs/24), que son JSON sobre WebSocket y viven acá por la misma
razón que los `.proto` — es el repo neutral que consumen tanto kilden-core
como kilden-panel sin que ninguno dependa del otro.

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

Los `option go_package` apuntan a `github.com/freshworkstudio/kilden-protos`.
Mientras el módulo Go no esté publicado, los consumidores usan un `replace`
local apuntando a `../kilden-protos/gen/go` (el `go.mod` de ese directorio lo
escribe `make generate`).
