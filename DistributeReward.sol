// SPDX-License-Identifier: MIT
import "./MyRevengeNFT.sol";
import "./interfaces/IUniswapV2Router.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MRCVault.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity ^0.8.0;

interface IWETH { //BNB -> WBNB transfer interface
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}

contract DistributeReward is ReentrancyGuard {

    using SafeERC20 for IERC20;

    IWETH private WETH;
    address public constant dev = 0x408ECB06EF97705Afb02646ae1E5537F370a6bfB;
    address public NFTContract;
    address public LoveToken;
    address public constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public MRCVaultAddr;
    IUniswapV2Router02 public uniswapV2Router;
    
modifier notContract() { //Keeps the nonsense out
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

function swapBNBForCake(uint256 bnbAmount) private {

        WETH.deposit{value: bnbAmount}(); //first we go to the WBNB store and get some WBNB

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = CAKE;

        // now we're cookin with CAKE!
        uniswapV2Router.swapExactTokensForTokens(
            bnbAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }


    receive() external payable {
    }

    function distribute() public notContract nonReentrant {
        require(MyRevengeNFT(NFTContract).balanceOf(msg.sender) > 0); //Need to own an NFT to call this function.
        Love(LoveToken).transferFrom(msg.sender, deadAddress, 1e18); //Burns 10 LOVE tokens. Oh no!!
        uint256 balance = address(this).balance; //get the starting balance

        uint256 devReward = balance * 20 / 100; //I take my 20% cut
        _safeTransferBNB(dev, devReward);

        uint256 callReward =  balance * 3 / 100; //The function caller gets a nice cut, as a treat.
        _safeTransferBNB(msg.sender, callReward);

        uint256 remainingBNB = address(this).balance;
        swapBNBForCake(remainingBNB); //we take the remaining amount and send it to the pancakeswap router.

        vaultDeposit(); //call the vault transfer.

    }

    function vaultDeposit() internal {
        uint256 tokenAmount = ERC20(CAKE).balanceOf(address(this)); //We check to see how much CAKE we have.
        if (tokenAmount != 0){ //This should always be more than 0, but felt like this was a good idea to have.
        MRCVault(MRCVaultAddr).deposit(tokenAmount);
        }
    }

    function getCallRewardBalance() public view returns(uint256) { //this function exists so my front end can easily get the caller reward.
        uint256 balance = address(this).balance;
        uint256 callReward =  balance * 3 / 100;

        return callReward;
    }

    function _isContract(address addr) internal view returns (bool) { //keeps the nonsense out.
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }


    constructor(address _NFTContract, address _LoveToken, address _MRCVaultAddr) {
        NFTContract = _NFTContract;
        LoveToken = _LoveToken;
        MRCVaultAddr = _MRCVaultAddr;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        WETH = IWETH(uniswapV2Router.WETH());
        WETH.approve(address(uniswapV2Router), type(uint256).max);
        IERC20(CAKE).safeApprove(MRCVaultAddr, type(uint256).max);
    }
}
