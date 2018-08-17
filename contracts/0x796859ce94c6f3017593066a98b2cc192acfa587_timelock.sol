// Timelock
// lock withdrawal for a set time period
// @authors:
// Cody Burns &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4d0dbdac0c4d5daddd7f4d7dbd0cdc3d6c1c6dac79ad7dbd9">[email&#160;protected]</a>&gt;
// license: Apache 2.0
// version:

pragma solidity ^0.4.19;

// Intended use: lock withdrawal for a set time period
//
// Status: functional
// still needs:
// submit pr and issues to https://github.com/realcodywburns/
//version 0.2.0


contract timelock {

////////////////
//Global VARS//////////////////////////////////////////////////////////////////////////
//////////////

    uint public freezeBlocks = 2000;       //number of blocks to keep a lockers (2k)

///////////
//MAPPING/////////////////////////////////////////////////////////////////////////////
///////////

    struct locker{
      uint freedom;
      uint bal;
    }
    mapping (address =&gt; locker) public lockers;

///////////
//EVENTS////////////////////////////////////////////////////////////////////////////
//////////

    event Locked(address indexed locker, uint indexed amount);
    event Released(address indexed locker, uint indexed amount);

/////////////
//MODIFIERS////////////////////////////////////////////////////////////////////
////////////

//////////////
//Operations////////////////////////////////////////////////////////////////////////
//////////////

/* public functions */
    function() payable public {
        locker storage l = lockers[msg.sender];
        l.freedom =  block.number + freezeBlocks; //this will reset the freedom clock
        l.bal = l.bal + msg.value;

        Locked(msg.sender, msg.value);
    }

    function withdraw() public {
        locker storage l = lockers[msg.sender];
        require (block.number &gt; l.freedom &amp;&amp; l.bal &gt; 0);

        // avoid recursive call

        uint value = l.bal;
        l.bal = 0;
        msg.sender.transfer(value);
        Released(msg.sender, value);
    }

////////////
//OUTPUTS///////////////////////////////////////////////////////////////////////
//////////

////////////
//SAFETY ////////////////////////////////////////////////////////////////////
//////////


}