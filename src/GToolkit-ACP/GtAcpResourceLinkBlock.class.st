Class {
	#name : 'GtAcpResourceLinkBlock',
	#superclass : 'GtAcpContentBlock',
	#instVars : [
		'uri',
		'name',
		'mimeType',
		'title',
		'description'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpResourceLinkBlock class >> fromDictionary: aDictionary [
	^ self new
		metadata: aDictionary;
		uri: (aDictionary at: 'uri' ifAbsent: [ nil ]);
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		mimeType: (aDictionary at: 'mimeType' ifAbsent: [ nil ]);
		title: (aDictionary at: 'title' ifAbsent: [ nil ]);
		description: (aDictionary at: 'description' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> description [
	^ description
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> description: aString [
	description := aString
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> mimeType [
	^ mimeType
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> mimeType: aString [
	mimeType := aString
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> name [
	^ name
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> name: aString [
	name := aString
]

{ #category : 'printing' }
GtAcpResourceLinkBlock >> printOn: aStream [
	aStream nextPutAll: 'GtAcpResourceLinkBlock('.
	name ifNotNil: [ aStream nextPutAll: name ] ifNil: [ aStream nextPutAll: 'unknown' ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> title [
	^ title
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> title: aString [
	title := aString
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> uri [
	^ uri
]

{ #category : 'accessing' }
GtAcpResourceLinkBlock >> uri: aString [
	uri := aString
]
