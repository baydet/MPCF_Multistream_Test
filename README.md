#MultipeerConnectivity multistream test

This code proves that it is possible to create multiple active different MCSessions between 2 or more peers. Every MCSession can also manage multiple NSStreams.

##How to run

To run these tests you should pass a run-parameters to command line: test number and required parameters for this tests. these tests are described in `AppDelegate.swift`.

##Description

Test app contains several tests in `AppDelegate.swift` that are simulating different MPCF behaviours with the following results
 - `testHighLoadConnectA1B1B2A2` - session between 2 peers is established. Created virtual socket (2 NSStreams - from peer A to peer B and from B to A that sends data to B and relay it back to A). During relaying this data A is trying to initiate creation of new virtual socket to relay data. But it is failing randomly. Since Apple's docs don't give us clear answer I suppose that the reason is we have a kind of "busy" MCSession and we have no enough bandwith to initiate creation of the new virtual socket. This assumption is confirmed (`testPartiallyBusyConnection`) when I've tried to reduce max buffer size for NSStreams that relay data. This makes available to create new virtual sockets.
 - `testConnectA1B1B2A2AndBroadcast` - simple test to ensure that we don't losing data using MPCF during relay.
 - `testOneMasterManySlavesConnection` - to ensure that it is available to manage multible browser's peers with the same advertiser's MCSession
 - `test3Peers` - this test proves possibility of having multiple MCSessions with the same serviceType but different MCPeerID. Each MCSession waiting to establising connection with another peer. After establishing these connections each peer tries open virtual socket. After all virtual sockets are created each session starts relay data through these virtual sockets.
