//SPDX-License-Identifier : MIT

pragma solidity ^0.8.19;

//intertface from another contract this gives the parent contract access to call functions from an external contract
interface IERC20 {
    function transfer(address to, uint amount) external view returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract Faucet {

    address public owner;//
    IERC20 public token;//erc20 token address that needs to be initialized 
    uint256 public withdrawalAmount = 1000 * (10 ** 18);
    uint public locktime = 2 minutes;
    mapping (address => uint256) public nextWithdrawTime; //mapping to store a next withdraw time from faucet
    
    event Deposit(address indexed from, uint256 indexed amount);
    event Withdrawal(address indexed to, uint256 indexed amount);


    constructor(address tokenAddress) payable {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function requestTestFunds() public {
        require(msg.sender != address(0), "invalid address"); //address mustb be valid
        require(token.balanceOf(address(this)) >= withdrawalAmount, "insufficient faucet balance");//ensure that faucet balance is sufficient enough
        require(block.timestamp >= nextWithdrawTime[msg.sender], "wait untill 2 minutes");

        nextWithdrawTime[msg.sender] = block.timestamp + locktime;
        token.transfer(msg.sender, withdrawalAmount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function getBalance() external view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function setWithdrawAmount (uint256 amount) public onlyOwner returns (uint256) {
       return withdrawalAmount = amount * (10**18);
    }

    function setLockTime(uint256 amount) public onlyOwner returns(uint256) {
       return locktime = amount * 60 seconds;
    }

    function withdraw() external onlyOwner {
        emit Withdrawal(msg.sender, token.balanceOf(address(this)));
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }




}