// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PolypToken is ERC20Pausable, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000_000 * 10 ** 18;
    uint256 public constant INITIAL_SUPPLY = 2_000_000_000 * 10 ** 18;
    uint256 public constant TRANCHE_SIZE = 500_000_000 * 10 ** 18;

    uint256 public totalMinted;
    uint256 public unlockedTranches;
    uint256 public lastUnlockTime;
    uint256 public trancheCooldown = 365 days;

    event TokensMinted(address indexed to, uint256 amount);
    event TrancheUnlocked(address indexed to, uint256 amount, uint256 timestamp);
    event CooldownUpdated(uint256 newCooldown);

    constructor(address initialHolder) ERC20("Polyp$", "POLYP") Ownable(initialHolder) {
        _mint(initialHolder, INITIAL_SUPPLY);
        totalMinted = INITIAL_SUPPLY;
        emit TokensMinted(initialHolder, INITIAL_SUPPLY);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function unlockTranche(address to) public onlyOwner {
        require(block.timestamp >= lastUnlockTime + trancheCooldown, "PolypToken: Tranche cooldown active");
        require(totalMinted + TRANCHE_SIZE <= MAX_SUPPLY, "PolypToken: Max supply exceeded");

        _mint(to, TRANCHE_SIZE);
        totalMinted += TRANCHE_SIZE;
        unlockedTranches += 1;
        lastUnlockTime = block.timestamp;

        emit TrancheUnlocked(to, TRANCHE_SIZE, block.timestamp);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "PolypToken: Cannot exceed max supply");

        _mint(to, amount);
        totalMinted += amount;

        emit TokensMinted(to, amount);
    }

    function updateTrancheCooldown(uint256 newCooldownInSeconds) public onlyOwner {
        trancheCooldown = newCooldownInSeconds;
        emit CooldownUpdated(newCooldownInSeconds);
    }
}

