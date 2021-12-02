pragma solidity ^0.4.18;

import './Owned.sol';
import './ERC20.sol';
/**************************************************/
/*       Расширенный токен начинается здесь       */
/**************************************************/

contract MyToken is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    /* Это создает публичное событие на blockchain, которая будет уведомлять клиентов */
    event FrozenFunds(address target, bool frozen);

    /* Инициализирует контракт с начальными маркерами поставок для создателя контракта */
    function MyToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint8 tokendecimals
    ) TokenERC20(initialSupply, tokenName, tokenSymbol, tokendecimals) public {}

    /* Внутренний перевод, только может быть вызван этим договором */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Предотвращение передачи по адресу 0x0. Вместо этого используйте burn() 
        require (balanceOf[_from] >= _value);               // Проверьте, достаточно ли у отправителя
        require (balanceOf[_to] + _value > balanceOf[_to]); // Проверка на переполнение
        require(!frozenAccount[_from]);                     // Проверьте, заморожен ли отправитель
        require(!frozenAccount[_to]);                       // Проверьте, заморожен ли получатель
        balanceOf[_from] -= _value;                         // Вычитать из отправителя
        balanceOf[_to] += _value;                           // Добавить то же самое к получателю
        Transfer(_from, _to, _value);
    }
/*
/// @notice создать `mintedAmount` жетоны и отправить его на "целевой" 
/// @param целевой адрес для получения маркеров 
/// @param и mintedAmount количество жетонов он получит
*/
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
/*
/// @notice ' заморозить? Запретить / разрешить отправку и получение маркеров` `target` 
/// @param с целевого адреса должны быть заморожены 
/// @param либо заморозить его или нет
*/
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
/*
/// @notice позволяют пользователям купить маркеры для newBuyPrice` Eth и продают жетоны для newSellPrice` етн 
/// @param и newSellPrice пользователи могут продать контракт 
/// @param newBuyPrice цене можете купить договор
*/
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

/*// @notice, купить маркеры от договора путем направления эфир */
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // вычисляет сумму
        _transfer(this, msg.sender, amount);              // осуществляет переводы
    }
/*
/// @notice продавать "сумма" контракта 
/// @param количество маркеров, которые будут проданы
*/
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);      // проверяет, достаточно ли эфира для покупки
        _transfer(msg.sender, this, amount);              // осуществляет переводы
        msg.sender.transfer(amount * sellPrice);          // посылает в эфир продавца. Важно сделать это в прошлом, чтобы избежать рекурсии атак
    }
}
