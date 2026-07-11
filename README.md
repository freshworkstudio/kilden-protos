# kilden-protos

Contratos protobuf de Kilden. El `Envelope` (proto/events/v1) es el contrato
central de todo el pipeline: cualquier cambio acá afecta a todos los servicios.

```bash
make lint       # buf lint
make generate   # codegen Go (kilden-core) y PHP (kilden-panel) en gen/
make breaking   # bloquea cambios incompatibles contra main
```

Los `option go_package` apuntan a `github.com/freshworkstudio/kilden-protos`.
Mientras el módulo Go no esté publicado, los consumidores usan un `replace`
local apuntando a `../kilden-protos/gen/go` (el `go.mod` de ese directorio lo
escribe `make generate`).
