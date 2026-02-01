Class {
	#name : 'GtAcpLogEntry',
	#superclass : 'Object',
	#instVars : [
		'timestamp',
		'direction',
		'message'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpLogEntry class >> received: aDictionary [
	^ self new
		initDirection: #received message: aDictionary
]

{ #category : 'instance creation' }
GtAcpLogEntry class >> sent: aDictionary [
	^ self new
		initDirection: #sent message: aDictionary
]

{ #category : 'accessing' }
GtAcpLogEntry >> direction [
	^ direction
]

{ #category : 'gt-views' }
GtAcpLogEntry >> gtMessageFor: aView [
	<gtView>
	^ aView textEditor
		title: 'JSON';
		priority: 1;
		text: [ STONJSON toStringPretty: message ]
]

{ #category : 'initialization' }
GtAcpLogEntry >> initDirection: aSymbol message: aDictionary [
	timestamp := DateAndTime now.
	direction := aSymbol.
	message := aDictionary
]

{ #category : 'testing' }
GtAcpLogEntry >> isReceived [
	^ direction = #received
]

{ #category : 'testing' }
GtAcpLogEntry >> isSent [
	^ direction = #sent
]

{ #category : 'accessing' }
GtAcpLogEntry >> message [
	^ message
]

{ #category : 'printing' }
GtAcpLogEntry >> printOn: aStream [
	aStream
		nextPutAll: timestamp asTime print24;
		nextPutAll: ' ';
		nextPutAll: (direction = #sent ifTrue: [ '→' ] ifFalse: [ '←' ]);
		nextPutAll: ' '.
	(message includesKey: 'method')
		ifTrue: [ aStream nextPutAll: (message at: 'method') ]
		ifFalse: [ (message includesKey: 'result')
			ifTrue: [ aStream nextPutAll: 'result' ]
			ifFalse: [ aStream nextPutAll: 'error' ] ].
	(message includesKey: 'id')
		ifTrue: [ aStream nextPutAll: ' #'; print: (message at: 'id') ]
]

{ #category : 'accessing' }
GtAcpLogEntry >> timestamp [
	^ timestamp
]
