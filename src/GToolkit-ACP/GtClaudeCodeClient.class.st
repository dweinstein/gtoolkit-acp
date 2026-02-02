Class {
	#name : 'GtClaudeCodeClient',
	#superclass : 'GtAcpClient',
	#classInstVars : [
		'programPath',
		'programArgs',
		'defaultCwd'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'configuration' }
GtClaudeCodeClient class >> defaultCwd [
	^ defaultCwd ifNil: [ '/Users/user/personal/gt' ]
]

{ #category : 'configuration' }
GtClaudeCodeClient class >> defaultCwd: aString [
	defaultCwd := aString
]

{ #category : 'launching' }
GtClaudeCodeClient class >> launch [
	"Create a new Claude Code client, connect, initialize, and open a session in the default CWD"
	^ self launchIn: self defaultCwd
]

{ #category : 'launching' }
GtClaudeCodeClient class >> launchIn: aCwdString [
	"Create a new Claude Code client, connect, initialize, and open a session in the given CWD.
	Returns the client. The session is created asynchronously."
	| client |
	client := self new.
	client connect.
	client initializeDo: [ :result |
		client newSessionIn: aCwdString do: [ :session | ] onError: [ :err |
			Transcript crShow: 'Session error: ', err printString ] ]
	onError: [ :err |
		Transcript crShow: 'Init error: ', err printString ].
	^ client
]

{ #category : 'configuration' }
GtClaudeCodeClient class >> programArgs [
	^ programArgs ifNil: [ #('/Users/user/personal/acp/claude-code-acp/dist/index.js') ]
]

{ #category : 'configuration' }
GtClaudeCodeClient class >> programArgs: anArray [
	programArgs := anArray
]

{ #category : 'configuration' }
GtClaudeCodeClient class >> programPath [
	^ programPath ifNil: [ '/Users/user/.nvm/versions/node/v20.12.2/bin/node' ]
]

{ #category : 'configuration' }
GtClaudeCodeClient class >> programPath: aString [
	programPath := aString
]

{ #category : 'connecting' }
GtClaudeCodeClient >> connect [
	"Connect using the class-side configured program path and args"
	self connectTo: self class programPath args: self class programArgs
]

{ #category : 'printing' }
GtClaudeCodeClient >> printOn: aStream [
	aStream 
		nextPutAll: 'ClaudeCode(';
		nextPutAll: (self isConnected ifTrue: [ 'connected' ] ifFalse: [ 'disconnected' ]);
		nextPutAll: ' - ';
		print: sessions size;
		nextPutAll: ' sessions';
		nextPut: $)
]
