.PHONY: lint generate breaking

lint:
	buf lint

# gen/ is a build artifact (gitignored). The go.mod written below makes
# gen/go usable as a local `replace` target until the module is published.
generate:
	buf generate
	printf 'module github.com/freshworkstudio/kilden-protos/gen/go\n\ngo 1.22\n\nrequire google.golang.org/protobuf v1.34.2\n' > gen/go/go.mod
	cd gen/go && go mod tidy

# compara contra main para impedir cambios incompatibles en el wire
breaking:
	buf breaking --against '.git#branch=main'
