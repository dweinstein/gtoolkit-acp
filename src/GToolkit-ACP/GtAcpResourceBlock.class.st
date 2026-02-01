Class {
	#name : 'GtAcpResourceBlock',
	#superclass : 'GtAcpContentBlock',
	#instVars : [
		'resource'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpResourceBlock class >> fromDictionary: aDictionary [
	^ self new
		metadata: aDictionary;
		resource: (aDictionary at: 'resource' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'printing' }
GtAcpResourceBlock >> printOn: aStream [
	aStream nextPutAll: 'GtAcpResourceBlock('.
	resource ifNotNil: [ 
		aStream nextPutAll: (resource at: 'uri' ifAbsent: [ 'unknown' ]) ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpResourceBlock >> resource [
	^ resource
]

{ #category : 'accessing' }
GtAcpResourceBlock >> resource: anObject [
	resource := anObject
]
