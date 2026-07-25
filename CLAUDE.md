# kilden-protos — contexto para Claude Code

Este repo define los contratos de wire de Kilden (contexto general en el
CLAUDE.md del wrapper padre y en ../docs/).

Reglas propias de este repo:

1. **`Envelope.properties` es string JSON opaco. Nunca tipearlo** ni agregarle
   mensajes estructurados paralelos. Las properties son schema-less por diseño.
2. **Nunca reutilizar ni renumerar field numbers.** Campos eliminados se marcan
   `reserved`. `make breaking` debe pasar siempre — el pipeline tiene mensajes
   en vuelo con versiones viejas del schema (retención de días en Kafka).
3. Paquetes versionados (`events.v1`). Cambios incompatibles = paquete nuevo
   (`events.v2`) y migración explícita, no edición in-place.
4. Enums siempre con valor `_UNSPECIFIED = 0` y prefijo del nombre del enum
   (lint STANDARD de buf lo exige).
5. **`gen/` SE COMMITEA.** Los consumidores (kilden-core por `replace` a
   `gen/go`, el panel por `gen/php`) y su CI lo usan tal cual, sin la
   toolchain de buf: el CI de kilden-core clona este repo y compila contra
   `gen/go` directamente. Todo cambio a un `.proto` va con su
   `make generate` **en el mismo commit** — si no, el repo mergea verde y el
   build de core se cae con "has no field or method X" (pasó con `group_ids`,
   PR #9).
6. PII: la IP no viaja en el envelope; solo la Geo derivada. Mantenerlo así
   salvo decisión explícita documentada en ../docs/.
7. Idioma: comentarios en los .proto y mensajes de commit en INGLÉS; este
   doc y el README pueden estar en español.
