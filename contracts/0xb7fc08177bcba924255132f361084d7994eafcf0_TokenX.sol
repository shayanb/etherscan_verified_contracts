pragma solidity ^0.4.24;

contract TokenX {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    uint private constant MAX_UINT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    string public constant name = &quot;Token X&quot;;
    string public constant symbol = &quot;TKX&quot;;
    uint public constant decimals = 2;
    uint public constant totalSupply = 10000 * (10 ** decimals);

    mapping (address =&gt; uint) public balanceOf;
    mapping (address =&gt; mapping (address =&gt; uint)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(0, msg.sender, totalSupply);
    }

    function transfer(address to, uint amount) external returns (bool) {
        require(to != address(this));
        require(to != 0);
        uint balanceOfMsgSender = balanceOf[msg.sender];
        require(balanceOfMsgSender &gt;= amount);
        balanceOf[msg.sender] = balanceOfMsgSender - amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        require(to != address(this));
        require(to != 0);
        uint allowanceMsgSender = allowance[from][msg.sender];
        require(allowanceMsgSender &gt;= amount);
        if (allowanceMsgSender != MAX_UINT) {
            allowance[from][msg.sender] = allowanceMsgSender - amount;
        }
        uint balanceOfFrom = balanceOf[from];
        require(balanceOfFrom &gt;= amount);
        balanceOf[from] = balanceOfFrom - amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}