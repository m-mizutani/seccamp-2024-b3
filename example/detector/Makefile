MOCK_GO=mock.go

all: $(MOCK_GO)

$(MOCK_GO): interfaces.go
	moq -out $(MOCK_GO) . Inquirer RowIterator Publisher PublishResult
