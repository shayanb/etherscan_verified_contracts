pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// &#39;KYRO Investment&#39;
//
// NAME     : KYRO Inv
// Symbol   : KR
// Total supply: 3,000,000,000
// Decimals    : 18
//
// Enjoy.
//
// (c) by Moritz Neto &amp; Daniel Bar with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
// ----------------------------------------------------------------------------
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b &lt;= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c &gt;= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a &gt;= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a &lt; b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a &gt;= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a &lt; b ? a : b;
    }
}

contract ERC20Basic {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 {
    uint256 public totalSupply;

    bool public transfersEnabled;

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address =&gt; uint256) balances;

    /**
    * @dev protection against short address attack
    */
    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }


    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[msg.sender]);
        require(transfersEnabled);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping(address =&gt; mapping(address =&gt; uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool) {
        require(_to != address(0));
        require(_value &lt;= balances[_from]);
        require(_value &lt;= allowed[_from][msg.sender]);
        require(transfersEnabled);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue &gt; oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract KYROInv is StandardToken {

    string public constant name = &quot;KYRO Inv&quot;;
    string public constant symbol = &quot;KR&quot;;
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 3 * 10**9 * (10**uint256(decimals));
    uint256 public weiRaised;
    uint256 public tokenAllocated;
    address public owner;
    bool public saleToken = true;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function KYROInv() public {
        totalSupply = INITIAL_SUPPLY;
        owner = msg.sender;
        //owner = msg.sender; // for testing
        balances[owner] = INITIAL_SUPPLY;
        tokenAllocated = 0;
        transfersEnabled = true;
    }

    // fallback function can be used to buy tokens
    function() payable public {
        buyTokens(msg.sender);
    }

    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        require(saleToken == true);
        address wallet = owner;
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {revert();}
        weiRaised = weiRaised.add(weiAmount);
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);

        TokenPurchase(_investor, weiAmount, tokens);
        wallet.transfer(weiAmount);
        return tokens;
    }

    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
        if (addTokens &gt; balances[owner]) {
            TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }

    /**
    * If the user sends 0 ether, he receives 200 
    * If he sends 0.001 ether, he receives 3,000 
    * If he sends 0.005 ether, he receives 15,000 +5%
    * If he sends 0.01 ether, he receives 30,000 +10%
    * If he sends 0.1 ether he receives 300,000 +15%
    * If he sends 1 ether, he receives 3,000,000 +20%
    */
    function getTotalAmountOfTokens(uint256 _weiAmount) internal pure returns (uint256) {
        uint256 amountOfTokens = 0;
        if(_weiAmount == 0){
            amountOfTokens = 250 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.001 ether){
            amountOfTokens = 3 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.002 ether){
            amountOfTokens = 6 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.003 ether){
            amountOfTokens = 9 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.004 ether){
            amountOfTokens = 12 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.005 ether){
            amountOfTokens = 15750 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.006 ether){
            amountOfTokens = 18900 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.007 ether){
            amountOfTokens = 22050 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.008 ether){
            amountOfTokens = 25200 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.009 ether){
            amountOfTokens = 28350 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.01 ether){
            amountOfTokens = 33 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.02 ether){
            amountOfTokens = 66 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.03 ether){
            amountOfTokens = 99 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.04 ether){
            amountOfTokens = 132 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.05 ether){
            amountOfTokens = 165 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.06 ether){
            amountOfTokens = 198 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.07 ether){
            amountOfTokens = 231 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.08 ether){
            amountOfTokens = 264 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.09 ether){
            amountOfTokens = 295 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.1 ether){
            amountOfTokens = 345 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.2 ether){
            amountOfTokens = 690 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.3 ether){
            amountOfTokens = 1035 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.4 ether){
            amountOfTokens = 1380 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.5 ether){
            amountOfTokens = 1725 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.6 ether){
            amountOfTokens = 2070 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.7 ether){
            amountOfTokens = 2415 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.8 ether){
            amountOfTokens = 2760 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.9 ether){
            amountOfTokens = 3450 * 10**3 * (10**uint256(decimals));
        }
        if( _weiAmount == 1 ether){
            amountOfTokens = 3600 * 10**3 * (10**uint256(decimals));
        }
        return amountOfTokens;
    }


    function mint(address _to, uint256 _amount, address _owner) internal returns (bool) {
        require(_to != address(0));
        require(_amount &lt;= balances[_owner]);

        balances[_to] = balances[_to].add(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        Transfer(_owner, _to, _amount);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function startSale() public onlyOwner {
        saleToken = true;
    }

    function stopSale() public onlyOwner {
        saleToken = false;
    }

    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }

    /**
     * Peterson&#39;s Law Protection
     * Claim tokens
     */
    function claimTokens() public onlyOwner {
        owner.transfer(this.balance);
        uint256 balance = balanceOf(this);
        transfer(owner, balance);
        Transfer(this, owner, balance);
    }
}