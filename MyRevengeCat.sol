// SPDX-License-Identifier: MIT

/*
  inspired by (w) (a) (g) (m) (i) by dom
*/
import "./Love.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity ^0.8.0;

contract MyRevengeCat is Ownable, ReentrancyGuard {

    bool _birthed;
    uint256 public constant interactPrice = 0.05 ether;
    address public immutable LoveToken;
    address public immutable distributeReward;
    event CaretakerLoved(address indexed caretaker, uint256 indexed amount);
    uint256 lastFeedBlock;
    uint256 lastCleanBlock;
    uint256 lastPlayBlock;
    uint256 lastSleepBlock;
    
    uint256 internal hunger;
    uint256 internal uncleanliness;
    uint256 internal boredom;
    uint256 internal sleepiness;
    
    constructor(address _LoveToken, address _distributeReward) Ownable() {
        distributeReward = _distributeReward;
        LoveToken = _LoveToken;
        //We initialize all of the needed info at construction.
        lastFeedBlock = block.number;
        lastCleanBlock = block.number;
        lastPlayBlock = block.number;
        lastSleepBlock = block.number;
        
        hunger = 100;
        uncleanliness = 100;
        boredom = 100;
        sleepiness = 100;
    }
    
    function sendLove(address caretaker, uint256 amount) internal {
        Love(LoveToken).mint(caretaker, amount);
        emit CaretakerLoved(caretaker, amount);
    }

     function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function feed() public payable nonReentrant {
        require(getAlive(), "It appears they are no longer with us.");
        require(getHunger() <= 75, "I'm not hungry!"); //So we don't go over 100.
        require(msg.value == interactPrice); //No funny business on the contract side, so people can't do whatever without the front end.

        _safeTransferBNB(distributeReward, interactPrice); //sends the BNB to the distribute reward contract

        lastFeedBlock = block.number;

        hunger = hunger + 25;
        
        if (boredom <= 5) {
           boredom = 0;
        } else {
           boredom = boredom - 5;
        }

        if (uncleanliness <= 3) {
           uncleanliness = 0;
        } else {
           uncleanliness = uncleanliness - 5;
        }

        sendLove(msg.sender, 1e18); //send the Love token!!
    }
    
    function clean() public payable nonReentrant {
        require(getAlive(), "It appears they are no longer with us.");
        require(getUncleanliness() <= 75, "I'm clean enough!");
        require(msg.value == interactPrice);

        _safeTransferBNB(distributeReward, interactPrice);

        lastCleanBlock = block.number;

        uncleanliness = uncleanliness + 25;
        
        sendLove(msg.sender, 1e18);
    }
    
    function play() public payable nonReentrant {
        require(getAlive(), "It appears they are no longer with us.");
        require(getBoredom() <= 75, "I'm not bored");
        require(msg.value == 0.05 ether);

        _safeTransferBNB(distributeReward, interactPrice);
        
        lastPlayBlock = block.number;
        
        boredom = boredom + 25;

        if (hunger <= 4) {
           hunger = 0;
        } else {
           hunger = hunger - 4;
        }

        if (sleepiness <= 3) {
           sleepiness = 0;
        } else {
           sleepiness = sleepiness - 3;
        }

        if (uncleanliness <= 2) {
           uncleanliness = 0;
        } else {
           uncleanliness = uncleanliness - 2;
        }

        sendLove(msg.sender, 1e18);
    }
    
    function sleep() public payable nonReentrant {
        require(getAlive(), "It appears they are no longer with us.");
        require(getSleepiness() <= 75, "I'm not sleepy at all!");
        require(msg.value == interactPrice);

        _safeTransferBNB(distributeReward, interactPrice);
        
        lastSleepBlock = block.number;

        sleepiness = sleepiness + 25;

        if (uncleanliness <= 5) {
           uncleanliness = 0;
        } else {
           uncleanliness = uncleanliness - 5;
        }
        
        sendLove(msg.sender, 1e18);
    }
    //I don't think Im going to keep this in the final contract, but do want it to be checked.

    // function revive() public payable nonReentrant {
    //     require(!getAlive(), "I'm not dead, what are you doing?");
    //     require(msg.value == interactPrice);

    //     payable(distributeReward).transfer(msg.value);

    //     lastFeedBlock = block.number;
    //     lastCleanBlock = block.number;
    //     lastPlayBlock = block.number;
    //     lastSleepBlock = block.number;

    //     boredom = 100;
    //     hunger = 100;
    //     sleepiness = 100;
    //     uncleanliness = 100;
    // } 
    // Just for testing the contract. Will be removed in final build.
    // function testState() public {
    //         boredom = 30;
    //         hunger = 50;
    //         sleepiness = 35;
    //         uncleanliness = 25;
    //     }
    
    function getStatus() public view returns (string memory) {
        uint256 mostNeeded = 100;
        
        string[4] memory goodStatus = [ //Here we give it a random-ish happy status as a default.
            "Hello, I'm doing great today!!",
            "*Purrs Affectionately*",
            "You're the best!",
            "I love you!"
        ];

        
        string memory status = goodStatus[block.number % 4]; //"random-ish"
        
        uint256 _hunger = getHunger();
        uint256 _uncleanliness = getUncleanliness();
        uint256 _boredom = getBoredom();
        uint256 _sleepiness = getSleepiness();
        
        if (!getAlive()) {
            return "The revenge cat appears to no longer be with us. Please revive them!";
        }
        //The goal here is to iterate through the status conditions and check each one against the other to find what it needs most.
        if (_hunger < 50 && _hunger < mostNeeded) {
            mostNeeded = _hunger;
            status = "I could use a snack..";
        }
        
        if (_uncleanliness < 50 && _uncleanliness < mostNeeded) {
            mostNeeded = _uncleanliness;
            status = "I stink. Can you bathe me?";
        }
        
        if (_boredom < 50 && _boredom < mostNeeded) {
            mostNeeded = _boredom;
            status = "I'm so bored. Play with me!";
        }
        
        if (_sleepiness < 50 && _sleepiness < mostNeeded) {
            mostNeeded = _sleepiness;
            status = "I'm tired..Can you cuddle with me?";
        }
        
        return status; //we return the most needed status.
    }
    
    function getAlive() public view returns (bool) { //This returns whether it's alive or not.
        return getHunger() > 0 && getUncleanliness() > 0 &&
            getBoredom() > 0 && getSleepiness() > 0;
    }
    
    function getHunger() public view returns (uint256) {
        uint256 decay = (block.number - lastFeedBlock) / 50;
        if (hunger <= decay) {
            return 0;
        }
        return hunger - decay; //Decays over time
    }

    function getUncleanliness() public view returns (uint256) {
        uint256 decay = (block.number - lastCleanBlock) / 50;
        if (uncleanliness <= decay) {
            return 0;
        }
        return uncleanliness - decay; //Decays over time
    }

    function getBoredom() public view returns (uint256) {
        uint256 decay = (block.number - lastPlayBlock) / 50;
        if (boredom <= decay) {
            return 0;
        }
        return boredom - decay; //Decays over time
    }

    function getSleepiness() public view returns (uint256) {
        uint256 decay = (block.number - lastSleepBlock) / 50;
        if (sleepiness <= decay) {
            return 0;
        }
        return sleepiness - decay; //Decays over time
    }

}