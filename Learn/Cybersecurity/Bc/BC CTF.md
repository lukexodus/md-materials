# Comprehensive CTF Blockchain Cheatsheet Syllabus (Kali Linux)

## Module 1: Blockchain Fundamentals

- Blockchain architecture and data structures
- Consensus mechanisms (PoW, PoS, PoA)
- Cryptographic primitives (hashing, digital signatures, elliptic curves)
- Transaction structure and validation
- Block creation and propagation
- Network topology and peer-to-peer communication

## Module 2: Ethereum & EVM Basics

- Ethereum protocol overview
- Account types (EOA vs Contract)
- Gas mechanics and transaction lifecycle
- EVM architecture and opcodes
- Storage layout (storage slots, memory, stack)
- ABI encoding/decoding
- Event logs and topics

## Module 3: Smart Contract Languages

- Solidity syntax and features
- Vyper fundamentals
- Contract compilation process
- Bytecode vs runtime code
- Constructor patterns
- Function visibility and modifiers
- Inheritance and libraries

## Module 4: Smart Contract Vulnerabilities

- Reentrancy attacks
- Integer overflow/underflow
- Access control issues
- Uninitialized storage pointers
- Delegatecall vulnerabilities
- Front-running and MEV
- Timestamp dependence
- tx.origin vs msg.sender
- Unchecked external calls
- DOS attacks
- Logic bugs and business logic flaws

## Module 5: Kali Linux Tools for Blockchain CTF

- Ethereum client setup (Geth, Ganache)
- Web3.py and Web3.js
- Foundry (forge, cast, anvil)
- Hardhat and Truffle
- Slither static analyzer
- Mythril symbolic executor
- Echidna fuzzer
- Manticore
- Etherscan and blockchain explorers

## Module 6: Reverse Engineering & Bytecode Analysis

- Disassembling smart contracts
- Decompilation tools (Panoramix, ethervm.io)
- Opcode reference and manual analysis
- Control flow graph reconstruction
- Storage slot identification
- Proxy pattern analysis
- Upgradeability mechanisms

## Module 7: Exploitation Techniques

- Contract interaction with Web3
- Custom transaction crafting
- Calldata manipulation
- Storage manipulation
- Selfdestruct exploitation
- Create2 address prediction
- Signature replay attacks
- Hash collision strategies

## Module 8: Private Key & Cryptography Attacks

- Weak randomness exploitation
- ECDSA signature vulnerabilities
- Nonce reuse attacks
- Brain wallet attacks
- Private key recovery techniques
- Hash function weaknesses
- Commitment scheme attacks

## Module 9: DeFi-Specific Vulnerabilities

- Oracle manipulation
- Flash loan attacks
- Price manipulation
- Liquidity pool exploits
- Slippage attacks
- Sandwich attacks
- Cross-protocol composability issues
- Governance attacks

## Module 10: Layer 2 & Advanced Protocols

- Rollup mechanics (Optimistic, ZK)
- State channel vulnerabilities
- Sidechain security
- Bridge exploits
- Cross-chain communication attacks

## Module 11: Forensics & Analysis

- Transaction tracing
- Event log parsing
- Memory and storage dumps
- Blockchain state examination
- Mempool monitoring
- Contract interaction history

## Module 12: CTF-Specific Techniques

- Challenge environment setup
- Local blockchain testing
- Script automation for exploits
- Flag extraction patterns
- Time-based challenges
- Multi-step exploit chains
- Cooperative contract patterns

## Module 13: Python Scripting for Blockchain CTF

- Web3.py automation
- Contract interaction scripts
- Bytecode manipulation
- Exploit payload generation
- Bruteforce and fuzzing scripts
- Custom RPC interactions

## Module 14: Debugging & Development

- Remix IDE usage
- Hardhat debugging
- Foundry testing framework
- Console logging in contracts
- Transaction simulation
- Fork testing against mainnet

## Module 15: Common CTF Patterns

- Puzzle wallet challenges
- Token manipulation challenges
- Vault/bank challenges
- Voting/governance challenges
- Lottery/randomness challenges
- NFT/ERC721 challenges
- Upgrade challenges
- Multi-contract systems