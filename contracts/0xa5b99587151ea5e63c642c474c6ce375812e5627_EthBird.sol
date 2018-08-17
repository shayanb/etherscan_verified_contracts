pragma solidity ^0.4.0;

contract EthBird {
    
    address public owner;
    address highScoreUser;
    
    uint currentHighScore = 0;
    uint contestStartTime = now;
    
    mapping(address =&gt; bool) paidUsers;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function EthBird() public {
        owner = msg.sender;
    }
    
    function payEntryFee() public payable  {
        if (msg.value &gt;= 0.001 ether) {
            paidUsers[msg.sender] = true;
        }
    }

    function getCurrentHighscore() public constant returns (uint) {
        return currentHighScore;
    }
    
    function getCurrentHighscoreUser() public constant returns (address) {
        return highScoreUser;
    }
    
    function getCurrentJackpot() public constant returns (uint) {
        return address(this).balance;
    }
    
    function getNextPayoutEstimation() public constant returns (uint) {
        return (contestStartTime + 1 days) - now;
    }
    
    function recordHighScore(uint score, address userToScore)  public onlyOwner returns (address) {
        if(paidUsers[userToScore]){
            if(score &gt; 0 &amp;&amp; score &gt;= currentHighScore){
                highScoreUser = userToScore;
                currentHighScore = score;
            }
            if(now &gt;= contestStartTime + 1 days){
                awardHighScore();   
            }
        }
        return userToScore;
    }
    
    function awardHighScore() public onlyOwner {
        uint256 ownerCommision = address(this).balance / 10;
        address(owner).transfer(ownerCommision);
        address(highScoreUser).transfer(address(this).balance);
        contestStartTime = now;
    }
}