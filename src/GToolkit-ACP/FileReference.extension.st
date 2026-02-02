Extension { #name : 'FileReference' }

{ #category : '*GToolkit-ACP' }
FileReference >> gtActionOpenClaudeCodeSessionFor: anAction [
	<gtAction>
	self isDirectory ifFalse: [ ^ anAction noAction ].
	^ anAction button
		tooltip: 'Open Claude Code session here';
		icon: BrGlamorousVectorIcons play;
		action: [ :aButton |
			| client |
			client := GtClaudeCodeClient launchIn: self pathString.
			aButton phlow spawnObject: GtAcpClientRegistry uniqueInstance ]
]
