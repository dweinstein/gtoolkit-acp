Class {
	#name : 'GtAcpContentBlock',
	#superclass : 'Object',
	#instVars : [
		'metadata'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpContentBlock class >> fromDictionary: aDictionary [
	| type |
	type := aDictionary at: 'type' ifAbsent: [ ^ self new metadata: aDictionary; yourself ].
	type = 'text' ifTrue: [ ^ GtAcpTextBlock fromDictionary: aDictionary ].
	type = 'image' ifTrue: [ ^ GtAcpImageBlock fromDictionary: aDictionary ].
	type = 'resource' ifTrue: [ ^ GtAcpResourceBlock fromDictionary: aDictionary ].
	type = 'resource_link' ifTrue: [ ^ GtAcpResourceLinkBlock fromDictionary: aDictionary ].
	^ self new metadata: aDictionary; yourself
]

{ #category : 'accessing' }
GtAcpContentBlock >> metadata [
	^ metadata
]

{ #category : 'accessing' }
GtAcpContentBlock >> metadata: anObject [
	metadata := anObject
]

{ #category : 'printing' }
GtAcpContentBlock >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: (metadata ifNotNil: [ metadata at: 'type' ifAbsent: [ 'unknown' ] ] ifNil: [ 'unknown' ]).
	aStream nextPut: $)
]
