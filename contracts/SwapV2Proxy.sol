// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/**
 * @title SwapV2Proxy
 */
contract SwapV2Proxy is Ownable, IUniswapV2Callee {
    using SafeMath for uint256;

    address private Authorized;

    address private WETH;
    
    // constructor
    constructor () {}

    // receive [external]
    receive () external payable {}

    // initiate [external]
    // "external owner call for multi-call atomic swap"
    // - aot : asset of trade for initial transaction payment
    // - val : amount of asset of trade for transaction
    // - dst : multi-liquidity pool destination pathway
    function initiate (address aot, uint256 val, address[] calldata dst) external onlyOwner {

    }

    // uniswapV2Call [IUniswapV2Callee]
    // "interface smart contract override mid-swap integration method"
    // - act  : initiation account address of transaction
    // - a0   : token0 amount received from liquidity pool
    // - a1   : token1 amount received from liquidity pool
    // - data : transaction data for mid-swap process actions
    function uniswapV2Call (address act, uint a0, uint a1, bytes calldata data) external override {
        require(_msgSender() == Authorized,                   "Error: Unauthorized");
        require(address(act) == address(this),                "Error: Unauthenticated");
        require((a0 == 0 && a1 != 0) || (a0 != 0 && a1 == 0), "Error: Inconsistency");

        // payment asset & value
        ( address aot, uint256 val ) = abi.decode(data, (address, uint256));

        // send liquidity pool payment of asset partner
        assert(IERC20(aot).transfer(_msgSender(), val));
    }

    // execute [private]
    // "private execution of swap transaction"
    // - aot  : current asset of trade from pair using partner as payment
    // - val  : amount of partner asset
    // - dst  : liquidity pool pair destination
    // - data : mid-swap transaction method data
    function execute (address aot, uint256 val, address dst, bytes memory data) private returns (bool) {
        // fetch liquidity pool pair
        IUniswapV2Pair pair = IUniswapV2Pair(dst);

        // fetch pair tokens & assert asset of trade is included
        address token0 = pair.token0();
        address token1 = pair.token1();
        assert(token0 == aot || token1 == aot);

        // fetch pair liquidity reserves & ensure values
        ( uint r0, uint r1, ) = pair.getReserves();
        assert(r0 > 0 && r1 > 0);

        // sort reserves based on asset of trade
        ( uint reserve0, uint reserve1 ) = token0 == aot ? (r0, r1) : (r1, r0);

        // calculate swap amount and set amt of trade
        uint fee         = val.mul(997);
        uint numerator   = fee.mul(reserve1);
        uint denominator = reserve0.mul(1000).add(fee);
        uint amount      = numerator / denominator;

        // sort swap transaction values
        ( uint a0, uint a1 ) = token0 == aot ? (amount, uint(0)) : (uint(0), amount);

        // set authorized address
        Authorized = address(pair);

        // initiate swap method & return status
        pair.swap(a0, a1, address(this), data);
        return true;
    }

}