// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CTXAirdrop is Ownable {
    IERC20 public immutable token;
    bytes32 public merkleRoot;
    address public treasury;

    mapping(address => bool) public claimed;

    event Claimed(address indexed user, uint256 amount);
    event MerkleRootUpdated(bytes32 indexed newRoot);
    event TreasuryUpdated(address indexed newTreasury);
    event TokensWithdrawn(address indexed to, uint256 amount);

    constructor(
        address initialOwner,
        address tokenAddress,
        bytes32 initialMerkleRoot,
        address treasuryAddress
    ) Ownable(initialOwner) {
        require(tokenAddress != address(0), "Invalid token");
        require(treasuryAddress != address(0), "Invalid treasury");

        token = IERC20(tokenAddress);
        merkleRoot = initialMerkleRoot;
        treasury = treasuryAddress;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(!claimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        claimed[msg.sender] = true;

        require(token.transfer(msg.sender, amount), "Transfer failed");

        emit Claimed(msg.sender, amount);
    }

    function setMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        merkleRoot = newMerkleRoot;
        emit MerkleRootUpdated(newMerkleRoot);
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "Invalid treasury");
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    function withdrawUnclaimed(uint256 amount) external onlyOwner {
        require(token.transfer(treasury, amount), "Withdraw failed");
        emit TokensWithdrawn(treasury, amount);
    }

    function isClaimed(address user) external view returns (bool) {
        return claimed[user];
    }
}
