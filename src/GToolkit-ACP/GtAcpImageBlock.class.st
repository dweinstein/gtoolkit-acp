Class {
	#name : 'GtAcpImageBlock',
	#superclass : 'GtAcpContentBlock',
	#instVars : [
		'data',
		'mimeType',
		'uri'
	],
	#category : 'GToolkit-ACP',
	#package : 'GToolkit-ACP'
}

{ #category : 'instance creation' }
GtAcpImageBlock class >> fromDictionary: aDictionary [
	^ self new
		metadata: aDictionary;
		data: (aDictionary at: 'data' ifAbsent: [ nil ]);
		mimeType: (aDictionary at: 'mimeType' ifAbsent: [ nil ]);
		uri: (aDictionary at: 'uri' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'accessing' }
GtAcpImageBlock >> data [
	^ data
]

{ #category : 'accessing' }
GtAcpImageBlock >> data: aString [
	data := aString
]

{ #category : 'accessing' }
GtAcpImageBlock >> mimeType [
	^ mimeType
]

{ #category : 'accessing' }
GtAcpImageBlock >> mimeType: aString [
	mimeType := aString
]

{ #category : 'printing' }
GtAcpImageBlock >> printOn: aStream [
	aStream nextPutAll: 'GtAcpImageBlock('.
	mimeType ifNotNil: [ aStream nextPutAll: mimeType ] ifNil: [ aStream nextPutAll: 'unknown' ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GtAcpImageBlock >> uri [
	^ uri
]

{ #category : 'accessing' }
GtAcpImageBlock >> uri: aString [
	uri := aString
]
