Class {
	#name : 'BaselineOfGtoolkitAcp',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGtoolkitAcp',
	#package : 'BaselineOfGtoolkitAcp'
}

{ #category : 'baseline' }
BaselineOfGtoolkitAcp >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GToolkit-ACP'
		]
]
