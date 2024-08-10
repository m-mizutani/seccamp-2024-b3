MOCK_GO=mock.go

all: $(MOCK_GO)

$(MOCK_GO): adapters.go
	moq -out $(MOCK_GO) . HTTPClient Inserter
