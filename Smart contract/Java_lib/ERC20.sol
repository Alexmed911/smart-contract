pragma solidity ^0.4.18;

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 tokendecimals) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Обновить общее предложение с десятичной суммой
        balanceOf[msg.sender] = totalSupply;                // Отдаем создателю все начальные маркеры
        name = tokenName;                                   // Задайте имя для отображения
        symbol = tokenSymbol;                               // Установить символ для отображения
        decimals = tokendecimals;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0); // Предотвращение передачи по адресу 0x0. Вместо этого используйте burn()
        require(balanceOf[_from] >= _value); // Проверка, достаточно ли у отправителя
        require(balanceOf[_to] + _value > balanceOf[_to]); // Проверка на переполнение
        uint previousBalances = balanceOf[_from] + balanceOf[_to]; // Сохранить для утверждения в будущем
        balanceOf[_from] -= _value; // Вычитать из отправителя
        balanceOf[_to] += _value; // Добавить то же самое к получателю
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances); // Утверждает используются на использование статического анализа для поиска ошибок в коде. Они никогда не должны терпеть неудачу
    }


    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

}