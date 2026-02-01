Class {
	#name : 'GtAcpTransportExamples',
	#superclass : 'Object',
	#category : 'GToolkit-ACP-Examples',
	#package : 'GToolkit-ACP-Examples'
}

{ #category : 'examples' }
GtAcpTransportExamples >> requestResponseRoundtrip [
	"Send a JSON-RPC request to a shell script that reads it and sends back a proper result response.
	Tests the resultHandlers path."
	<gtExample>
	| transport result semaphore errorOccurred |
	transport := GtAcpTransport
		on: '/bin/bash'
		args: #('-c' 'while IFS= read -r line; do id=$(echo "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)[''id''])"); echo "{\"jsonrpc\":\"2.0\",\"id\":$id,\"result\":{\"status\":\"ok\"}}"; done').
	transport start.
	result := nil.
	errorOccurred := false.
	semaphore := Semaphore new.
	transport
		sendRequest: 'test/echo'
		params: (Dictionary new at: 'hello' put: 'world'; yourself)
		do: [ :res |
			result := res.
			semaphore signal ]
		onError: [ :err |
			errorOccurred := true.
			semaphore signal ].
	semaphore waitTimeoutSeconds: 5.
	self assert: errorOccurred not.
	self assert: result notNil.
	self assert: (result at: 'status') equals: 'ok'.
	transport terminate.
	^ transport
]

{ #category : 'examples' }
GtAcpTransportExamples >> respondToServerRequest [
	"Test server→client request handling and respondTo:result:.
	Uses a bash script that sends a JSON-RPC request to the client, then reads the client's response.
	The script sends back the client's response as a notification so we can verify it."
	<gtExample>
	| transport receivedResponse semaphore script |
	script := 'echo ''{"jsonrpc":"2.0","id":99,"method":"test/question","params":{"q":"answer?"}}''; IFS= read -r response; id=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[''id''])"); result=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d[''result'']))"); echo "{\"jsonrpc\":\"2.0\",\"method\":\"test/got_response\",\"params\":$result}"'.
	transport := GtAcpTransport on: '/bin/bash' args: { '-c'. script }.
	receivedResponse := nil.
	semaphore := Semaphore new.
	"Register handler for the server→client request"
	transport on: 'test/question' do: [ :params :fullMessage |
		transport respondTo: (fullMessage at: 'id') result: (Dictionary new at: 'answer' put: 'yes'; yourself) ].
	"Register handler to capture what the server got back"
	transport on: 'test/got_response' do: [ :params |
		receivedResponse := params.
		semaphore signal ].
	transport start.
	semaphore waitTimeoutSeconds: 5.
	self assert: receivedResponse notNil.
	self assert: (receivedResponse at: 'answer') equals: 'yes'.
	transport terminate.
	^ transport
]

{ #category : 'examples' }
GtAcpTransportExamples >> roundtripWithCat [
	"Send a JSON-RPC notification through cat and verify it echoes back via method handler.
	cat echoes stdin to stdout — so the message arrives back with its 'method' key,
	routing it to methodHandlers."
	<gtExample>
	| transport received semaphore |
	transport := self startedTransportWithCat.
	received := nil.
	semaphore := Semaphore new.
	transport on: 'test/ping' do: [ :params |
		received := params.
		semaphore signal ].
	transport sendNotification: 'test/ping' params: (Dictionary new at: 'value' put: 42; yourself).
	semaphore waitTimeoutSeconds: 2.
	self assert: received notNil.
	self assert: (received at: 'value') equals: 42.
	transport terminate.
	self assert: transport isRunning not.
	^ transport
]

{ #category : 'examples' }
GtAcpTransportExamples >> startedTransportWithCat [
	"Start a cat transport — should be running"
	<gtExample>
	| transport |
	transport := self transportWithCat.
	transport start.
	self assert: transport isRunning.
	^ transport
]

{ #category : 'examples' }
GtAcpTransportExamples >> transportWithCat [
	"Spawn cat as a subprocess — it echoes stdin back to stdout"
	<gtExample>
	| transport |
	transport := GtAcpTransport on: '/bin/cat'.
	self assert: transport isRunning not.
	self assert: transport program equals: '/bin/cat'.
	^ transport
]
