Class {
	#name : 'GtAcpTransport',
	#superclass : 'Object',
	#instVars : [
		'program',
		'arguments',
		'environment',
		'process',
		'stdout',
		'stdin',
		'stderr',
		'mutex',
		'messageHandler',
		'nextId',
		'resultHandlers',
		'errorHandlers',
		'methodHandlers',
		'pendingInput',
		'messageLog',
		'onExitBlock'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpTransport class >> on: aProgramPath [
	^ self new
		program: aProgramPath;
		yourself
]

{ #category : 'instance creation' }
GtAcpTransport class >> on: aProgramPath args: anArray [
	^ self new
		program: aProgramPath;
		arguments: anArray;
		yourself
]

{ #category : 'accessing' }
GtAcpTransport >> arguments [
	^ arguments
]

{ #category : 'accessing' }
GtAcpTransport >> arguments: anArray [
	arguments := anArray
]

{ #category : 'accessing' }
GtAcpTransport >> environment [
	^ environment ifNil: [ environment := Dictionary new ]
]

{ #category : 'accessing' }
GtAcpTransport >> environmentAt: key put: value [
	environment at: key put: value
]

{ #category : 'private' }
GtAcpTransport >> getNextId [
	| id |
	id := nextId.
	nextId := nextId + 1.
	^ id
]

{ #category : 'gt-views' }
GtAcpTransport >> gtMessageLogFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Log';
		priority: 10;
		items: [ messageLog reversed ];
		column: 'Time' text: [ :entry | entry timestamp asTime print24 ] width: 100;
		column: 'Dir' text: [ :entry | entry isSent ifTrue: [ '→ sent' ] ifFalse: [ '← recv' ] ] width: 80;
		column: 'Message' text: [ :entry | entry printString ];
		updateWhen: Announcement in: [ Announcer new ];
		actionUpdateButton
]

{ #category : 'gt-views' }
GtAcpTransport >> gtStatusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Status';
		priority: 1;
		items: [ {
			{ 'Program' . program ifNil: [ '(none)' ] }.
			{ 'Arguments' . arguments printString }.
			{ 'Running' . self isRunning printString }.
			{ 'Next ID' . nextId printString }.
			{ 'Pending handlers' . resultHandlers size printString }.
			{ 'Method handlers' . methodHandlers keys printString }.
			{ 'Messages logged' . messageLog size printString }.
		} ];
		column: 'Property' text: [ :pair | pair first ] width: 150;
		column: 'Value' text: [ :pair | pair second ]
]

{ #category : 'gt-views' }
GtAcpTransport >> gtTrafficFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Traffic';
		priority: 5;
		items: [ messageLog reversed ];
		column: 'Direction' text: [ :entry | entry direction ] width: 80;
		column: 'Timestamp' text: [ :entry | entry timestamp ] width: 150;
		column: 'Message' text: [ :entry | entry printString ]
]

{ #category : 'private' }
GtAcpTransport >> handleProcessExit [
	| exitBlock |
	exitBlock := onExitBlock.
	errorHandlers do: [ :anErrorHandler | anErrorHandler cull: 'Process exited' ].
	self terminate.
	exitBlock ifNotNil: [ exitBlock value ]
]

{ #category : 'private' }
GtAcpTransport >> handleUnknownError: aDictionary [
	"Error with no registered handler — ignore"
]

{ #category : 'private' }
GtAcpTransport >> handleUnknownMethod: aDictionary [
	"Server-to-client method with no registered handler — ignore"
]

{ #category : 'private' }
GtAcpTransport >> handleUnknownResult: aDictionary [
	"Result with no registered handler — ignore"
]

{ #category : 'initialization' }
GtAcpTransport >> initialize [
	super initialize.
	mutex := Mutex new.
	nextId := 1.
	resultHandlers := Dictionary new.
	errorHandlers := Dictionary new.
	methodHandlers := Dictionary new.
	pendingInput := ''.
	arguments := #().
	environment := Dictionary new.
	messageLog := OrderedCollection new
]

{ #category : 'testing' }
GtAcpTransport >> isRunning [
	^ process notNil and: [ process isRunning ]
]

{ #category : 'accessing' }
GtAcpTransport >> messageLog [
	^ messageLog
]

{ #category : 'registration' }
GtAcpTransport >> on: aMethod do: aBlock [
	aBlock
		ifNil: [ methodHandlers removeKey: aMethod ifAbsent: [  ] ]
		ifNotNil: [ methodHandlers at: aMethod put: aBlock ]
]

{ #category : 'accessing' }
GtAcpTransport >> onExit: aBlock [
	onExitBlock := aBlock
]

{ #category : 'printing' }
GtAcpTransport >> printOn: aStream [
	aStream
		nextPutAll: 'GtAcpTransport(';
		nextPutAll: (program ifNil: [ 'no program' ]);
		nextPutAll: ' - '.
	self isRunning
		ifTrue: [ aStream nextPutAll: 'running' ]
		ifFalse: [ aStream nextPutAll: 'stopped' ].
	aStream nextPut: $)
]

{ #category : 'private' }
GtAcpTransport >> processInput: aString [
	| lines |
	aString ifEmpty: [ ^ self ].
	pendingInput := pendingInput , aString.
	lines := pendingInput lines.
	"If the input doesn't end with a newline, the last element is a partial line"
	(pendingInput endsWith: String lf)
		ifTrue: [ pendingInput := '' ]
		ifFalse: [ pendingInput := lines last.
			lines := lines allButLast ].
	lines do: [ :line |
		line ifNotEmpty: [
			[ | json |
			json := STONJSON fromString: line.
			self processMessage: json ]
				on: Error
				do: [ :e | "Skip malformed JSON lines" ] ] ]
]

{ #category : 'private' }
GtAcpTransport >> processMessage: aDictionary [
	| id handler |
	messageLog add: (GtAcpLogEntry received: aDictionary).
	(aDictionary includesKey: 'result')
		ifTrue: [ id := aDictionary at: 'id' ifAbsent: [ 0 ].
			handler := resultHandlers at: id ifAbsent: [ nil ].
			resultHandlers removeKey: id ifAbsent: [  ].
			errorHandlers removeKey: id ifAbsent: [  ].
			^ handler
				ifNil: [ self handleUnknownResult: aDictionary ]
				ifNotNil: [ [ handler cull: aDictionary ] fork ] ].
	(aDictionary includesKey: 'error')
		ifTrue: [ id := aDictionary at: 'id' ifAbsent: [ 0 ].
			handler := errorHandlers at: id ifAbsent: [ nil ].
			resultHandlers removeKey: id ifAbsent: [  ].
			errorHandlers removeKey: id ifAbsent: [  ].
			^ handler
				ifNil: [ self handleUnknownError: aDictionary ]
				ifNotNil: [ [ handler cull: aDictionary ] fork ] ].
	(aDictionary includesKey: 'method')
		ifTrue: [ | method params |
			method := aDictionary at: 'method'.
			params := aDictionary at: 'params' ifAbsent: [ Dictionary new ].
			handler := methodHandlers at: method ifAbsent: [ nil ].
			^ handler
				ifNil: [ self handleUnknownMethod: aDictionary ]
				ifNotNil: [ [ handler cull: params cull: aDictionary ] fork ] ]
]

{ #category : 'accessing' }
GtAcpTransport >> program [
	^ program
]

{ #category : 'accessing' }
GtAcpTransport >> program: aString [
	program := aString
]

{ #category : 'sending' }
GtAcpTransport >> respondTo: requestId result: aResult [
	| message |
	(process isNil or: [ process isTerminated ])
		ifTrue: [ ^ self ].
	message := Dictionary new
			at: 'jsonrpc' put: '2.0';
			at: 'id' put: requestId;
			at: 'result' put: aResult;
			yourself.
	self writeMessage: message
]

{ #category : 'sending' }
GtAcpTransport >> sendNotification: aMethod params: aParams [
	| message |
	(process isNil or: [ process isTerminated ])
		ifTrue: [ ^ self ].
	message := Dictionary new
			at: 'jsonrpc' put: '2.0';
			at: 'method' put: aMethod;
			yourself.
	aParams ifNotNil: [ message at: 'params' put: aParams ].
	self writeMessage: message
]

{ #category : 'sending' }
GtAcpTransport >> sendRequest: aMethod params: aParams do: aBlock onError: errorBlock [
	| id message |
	(process isNil or: [ process isTerminated ])
		ifTrue: [ errorBlock cull: 'Process not running'.
			^ self ].
	id := self getNextId.
	resultHandlers
		at: id
		put: [ :data | aBlock cull: (data at: 'result' ifAbsent: [ Dictionary new ]) ].
	errorHandlers at: id put: errorBlock.
	message := Dictionary new
			at: 'jsonrpc' put: '2.0';
			at: 'id' put: id;
			at: 'method' put: aMethod;
			yourself.
	aParams ifNotNil: [ message at: 'params' put: aParams ].
	self writeMessage: message
]

{ #category : 'lifecycle' }
GtAcpTransport >> start [
	process := [ | builder |
		builder := (GtExternalProcessBuilder new: program)
			args: arguments;
			pipeStdin;
			pipeStdout;
			pipeStderr.
		self environment keysAndValuesDo: [ :key :value |
			builder env: key value: value ].
		builder spawn ]
			on: GtExternalProcessFailedToStart
			do: [ :exception | exception child ].
	stdout := process asynchronousStdout.
	stderr := process asynchronousStderr.
	stdin := process stdin.
	pendingInput := ''.
	messageHandler := stdout
			pollStringEvery: 20 milliseconds
			do: [ :str | self processInput: str ]
			onExit: [ self handleProcessExit ]
]

{ #category : 'accessing' }
GtAcpTransport >> stderrContents [
	"Read any available stderr output for debugging"
	^ stderr ifNil: [ '' ] ifNotNil: [ stderr pollString ifNil: [ '' ] ]
]

{ #category : 'lifecycle' }
GtAcpTransport >> terminate [
	process
		ifNotNil: [ process terminate.
			process := nil ].
	messageHandler
		ifNotNil: [ (messageHandler isTerminated or: [ messageHandler isTerminating ])
				ifFalse: [ messageHandler terminate ].
			messageHandler := nil ].
	stderr
		ifNotNil: [ stderr release.
			stderr := nil ].
	stdout
		ifNotNil: [ stdout release.
			stdout := nil ].
	stdin
		ifNotNil: [ stdin release.
			stdin := nil ].
	resultHandlers := Dictionary new.
	errorHandlers := Dictionary new.
	methodHandlers := Dictionary new.
	pendingInput := ''.
	onExitBlock := nil
]

{ #category : 'private' }
GtAcpTransport >> writeMessage: aDictionary [
	| jsonString |
	jsonString := STONJSON toString: aDictionary.
	messageLog add: (GtAcpLogEntry sent: aDictionary).
	mutex critical: [
		stdin
			nextPutAll: jsonString;
			nextPutAll: String lf ]
]
