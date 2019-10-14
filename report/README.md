# 作業1 報告
* 學生 : `王祥任`
* 學號 : `0616309`
---
### 概要
* 本次作業是要以`lex`實作一個`P語言`的`scanner`
* 該`scanner`會在掃描到需要傳遞給`parser`的`token`時，會將其訊息輸出，把該`token`列印出來。
* 而在掃描到不需要傳遞的`token`時(如`空白`)則不列印輸出。
* 唯獨在掃描到`newline(\n)`時，需要將該行的文本包含行號列印輸出。
* 有特別指定兩種`pseudocomment`來開啟或關閉列印`token`和列印`行號與文本`。

---
### 字元集
* 主要為`ASCII`字元集。
* 控制字元(`\n` `\t` 例外)不會用在語言定義中。
---
### 詞彙定義和`Scanner`訊息輸出
* 以下將定義語彙和在掃描時所對應的訊息輸出
* 主要有兩大類別，以分析出的`Token`是否會傳遞給`Parser`作區別
    * 會傳遞至Parser者
    > 1. Delimiters
    > 2. Arithmetic, Relational, and Logical Operaters
    > 3. Keywords
    > 4. Identifiers
    > 5. Integer Constants(`Decimal`or`Octal`)
    > 6. Float-Point Constants
    > 7. Scientific Notations
    > 8. String Constants
    
    * 不會傳遞至Parser者
    > 1. Whitespace
    > 2. Comments
    > 3. Pseudocomments
* 請注意 **`大小寫`** 是有區分的
---  
### 會被傳遞至`Parser`的`Token`
* 以下類別中的`Token`在無特殊指定情況下都會在被掃描到的時候輸出一個`Token Message`。
    * `Token Listing`
* 往後可以將其直接修改成回傳`Token`的類型給`Parser`。
---
#### 分隔符(Delimiters)

||Delimiter|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|:-:|:-:|
|comma|**`,`**|**`","`**|**`<,>`**|
|semicolon|**`;`**|**`";"`**|**`<;>`**|
|colon|**`:`**|**`":"`**|**`<:>`**|
|parentheses| **`(`**, **`)`**|**`"("`**, **`")"`**|**`<(>`**, **`<)>`**|
|square brackets| **`[`**, **`]`**|**`"["`**, **`"]"`**|**`<[>`**, **`<]>`**|
---

#### 算數、關係、邏輯運算子(Arithmetic, Relational, and Logical Operaters)

||Operator|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|:-:|:-:|
|addition|**`+`**|**`"+"`**|**`<+>`**|
|subtraction|**`-`**|**`"-"`**|**`<->`**|
|multiplication|**`*`**|**`"*"`**|**`<*>`**|
|division| **`/`**, **`mod`**|**`"/"`**, **`"mod"`**|**`</>`**, **`<mod>`**|
|assignment|**`:=`**|**`":="`**|**`<:=>`**|
|relational| **`<`**, **`<=`**, **`<>`**, **`>=`**, **`>`**, **`=`** |**`"<"`**, **`"<="`**, **`"<>"`**, **`">="`**, **`">"`**, **`"="`**|**`<<>`**, **`<<=>`**, **`<<>>`**, **`<>=>`**, **`<>>`**, **`<=>`**|
|logical|**`and`**, **`or`**, **`not`**|**`"and"`**, **`"or"`**, **`"not"`**|**`<and>`**, **`<or>`**, **`<not>`**|

* 比較需要注意的是，`mod` `and` `or` `not`，有可能和`Identifiers`的定義內容衝突。
* 所以可以依照`The rule given first is preferred`的原則，將其定義擺放在比`Identifers`還要早的位置。

---
#### 關鍵字(Keywords)

|Keyword|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|:-:|
|**`array`**|**`"array"`**|**`<KWarray>`**|
|**`begin`**|**`"begin"`**|**`<KWbegin>`**|
|**`boolean`**|**`"boolean"`**|**`<KWboolean>`**|
|**`def`**|**`"def"`**|**`<KWdef>`**|
|**`do`**|**`"do"`**|**`<KWdo>`**|
|**`else`**|**`"else"`**|**`<KWelse>`**|
|**`end`**|**`"end"`**|**`<KWend>`**|
|**`false`**|**`"false"`**|**`<KWfalse>`**|
|**`for`**|**`"for"`**|**`<KWfor>`**|
|**`integer`**|**`"integer"`**|**`<KWinteger>`**|
|**`if`**|**`"if"`**|**`<KWif>`**|
|**`of`**|**`"of"`**|**`<KWof>`**|
|**`print`**|**`"print"`**|**`<KWprint>`**|
|**`read`**|**`"read"`**|**`<KWread>`**|
|**`real`**|**`"real"`**|**`<KWreal>`**|
|**`string`**|**`"string"`**|**`<KWstring>`**|
|**`then`**|**`"then"`**|**`<KWthen>`**|
|**`to`**|**`"to"`**|**`<KWto>`**|
|**`true`**|**`"true"`**|**`<KWtrue>`**|
|**`return`**|**`"return"`**|**`<KWreturn>`**|
|**`var`**|**`"var"`**|**`<KWvar>`**|
|**`while`**|**`"while"`**|**`<KWwhile>`**|
* 和`Operators`中`mod` `and` `or` `not`相同，`Keywords`全部都有可能和`Identifiers`的定義內容衝突。
* 所以可以依照`The rule given first is preferred`的原則，將其定義擺放在比`Identifers`還要早的位置。

---
#### 識別字(Identifiers)
* 識別字(Identifier)是一串由字母和數字構成的字串，且必定由字母開頭。
* 由於識別字的定義十分廣闊，可能和`Keywords`或一些`Operators`衝突，所以必須將其規則放置在較後方。

|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|
|**`[a-zA-Z][0-9a-zA-Z]*`**|**`<id: {id_name}>`**|

> 例子

|Lexeme|Scanner Message|
|:-:|:-:|
|**`aB12c3D4`**|**`<id: aB12c3D4>`**|

---
#### 整數常數(Integer Constants)
* 由一連串數字構成。
    * 若由`0`開頭且跟隨其他數字，則假設為`八進位(octal)`
    * 其餘則假設為`十進位(decimal)`

* **十進位(Decimal)**
    * 開頭為非`0`且其後有無跟隨數字皆可。
    * 由於十進位數若開頭為`0`，便只有在單個`0`存在的情況下才會成立，所以獨立寫出來。

    |Regular Expression|Scanner Message for `Token`|
    |:-:|:-:|
    |**`([1-9][0-9]*)\|(0)`**|**`<intger: {decimal_intger}>`**|

    > 例子

    |Lexeme|Scanner Message|
    |:-:|:-:|
    |**`1024`**|**`<integer: 1024>`**|
    |**`0`**|**`<integer: 0>`**|


* **八進位(Octal)**
    * 開頭為`0`且其後必跟隨至少一數字。
    * 注意是八進位，所以數字只會包含`0-7`

    |Regular Expression|Scanner Message for `Token`|
    |:-:|:-:|
    |**`(0[0-7][0-7]*)`**|**`<oct_intger: {octal_intger}>`**|

    > 例子

    |Lexeme|Scanner Message|
    |:-:|:-:|
    |**`0024`**|**`<oct_integer: 0024>`**|
    
---
#### 浮點數常數(Float-Point Constants)
* 由`.`符號前後分割為整數和小數兩部分。
    * 整數部分只接受 **十進位整數** (參閱 **整數常數** )
    * 小數部分接受一連串數字，且不包含多餘`0`
        > 即只接受結尾非`0`，或是點後單`0`

|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|
|**`({Dec_Int}\.[0-9]*[1-9])\|({Dec_int}\.0)`**|**`<float: {float}>`**|

> 例子

|Lexeme|Scanner Message|
|:-:|:-:|
|**`1.0`**|**`<float: 1.0>`**|
|**`0.25`**|**`<float: 0.25>`**|    

---
#### 科學記號(Scientific Notations)
* 形式為`aeb`,`aEb`,`ae+b`,`ae-b`,`aE+b`,`aE-b`以上六種。
    * `a`可為 **十進位整數** 或 **浮點數**。
    * `b`可為 **十進位整數** 。

|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|
|**`({Dec_Int}\|{Float})[Ee][+\|-]?{Dec_Int}`**|**`<scientific: {scientific}>`**|

> 例子

|Lexeme|Scanner Message|
|:-:|:-:|
|**`123E-4`**|**`<scientific: 123E-4>`**|
|**`1.23e25`**|**`<scientific: 1.23e25>`**|    

___
#### 字串常數(String Constants)
* 由零或多個`ASCII`字元組成，且被`"`前後包裹住。
* 其中不可包含`\n`。
* 其中唯一的跳脫字元組是`""`，其將被轉譯成`"`。

|Regular Expression|Scanner Message for `Token`|
|:-:|:-:|
|**`\"[^\n\"]*((\"\")[^\n\"]*)*\"`**|**`<string: {string}>`**|

> 例子

|Lexeme|Scanner Message|
|:-:|:-:|
|**`"aa"`**|**`<string: aa>`**|
|**`"aa""bb"""`**|**`<string: aa"bb">`**|    

```cpp=
{String}  {
            // 去除兩側包裹的 "
            strncat(tempStringBuf, yytext+1, strlen(yytext)-2);
            
            // 掃瞄有無跳脫字元 ""
            int idx=0;
            while(idx<strlen(tempStringBuf)){
              strncat(StringBuf, tempStringBuf+idx, 1);
              
              // 存在，則跳過第二個 "
              if(tempStringBuf[idx]=='\"') idx+=2;
              else idx++;
            }
            
            // Token列出來
            tokenString(string, StringBuf);
            
            // Buffer結尾重定義
            tempStringBuf[0] = '\0';
            StringBuf[0] = '\0';
          }
```
___
### 不會被傳遞至Parser的Token
* 以下的`Token`在被掃瞄到時都不會輸出`Token Message`。
* 以下的`Token`都不會傳遞至`Parser`中。

---
#### 空白(Whitespace)
* 一連串的`(space)`, `\t`, `\n`。
* 但是`\n`有些特殊動作需要輸出，故分開處理。

* **`(space)`, `\t`**

    |Regular Expression|Scanner Message for `Token`|
    |:-:|:-:|
    |**`[ \t]+`**|NULL|

* **`\n`**
    * 在讀取到`\n`時，我們需要計算行號並視情況輸出來源檔案的文本和行號。
    * 且就算在`Comments`中還是要有同樣的行為。
    * 此項功能受`Pseduocomments`影響，可以透過其決定開啟或關閉。
    
    |Regular Expression|Scanner Message for `Token`|
    |:-:|:-:|
    |**`\n`**|**`{LineNum}: {SourceCode}`**|
    
    ```cpp=
    \n      {
              LIST; // 將掃描到的"\n"押入Buffer中
              if (Opt_S) 
                printf("%d: %s", linenum, buf); // 輸出文本和行號
              linenum++; // 計算行號
              buf[0] = '\0'; // 重定義Buffer結尾
            }
    ```
    
___
#### 註解(Comments)
* `C-style`
    * 由`/*`和`*/`兩者包裹文字，有可能大於一行。
    * 注意並不支援`巢狀包裹`，即`/*`永遠與其後第一個`*/`匹配為一組。
        
        > 由於這種特性，我們引入`STATE`的觀念。
        > 
    
    ```cpp=
    <INITIAL>"/*"  {LIST; BEGIN COMMENT; }
    <COMMENT>"*/"  {LIST; BEGIN INITIAL; }
    <COMMENT>.     {LIST; }
    
    <COMMENT>\n |
    \n          {
                    ...
                }
    ```
    * 在掃描到`/*`後，便逐步掃描其後的字元。
    * 若掃描到 **第一組** `*/`則跳出。
    * 若掃描到`\n`則必須完成其該有的行為(輸出文本和行號、計算行號)。
    
* `C++-style`
    * 由`//`起頭，且由`\n`結尾。
    * 但由於`\n`具有特殊的行為，所以並不包含入`Regular Expression`中。
    
    |Regular Expression|Scanner Message for `Token`|
    |:-:|:-:|
    |**`"//".*`**|NULL|

___
#### 偽註解(Pseudocomments)
* 若註解的開頭為以下四種組合，則對`Scanner`的輸出做特定調整。
* 和註解相同，其後應跟隨`\n`，但應`\n`有其特殊行為，故不寫入`Regular Expression`中。
    > 1. `//&S+`
    > 2. `//&S-`
    > 3. `//&T+`
    > 4. `//&T-`

|Regular Expression|Behavior|Meaning|
|:-:|:-:|:-:|
|**`"//&S+".*`**|`Opt_S=1`|啟動原始碼文本和行號輸出(預設)|
|**`"//&S-".*`**|`Opt_S=0`|關閉原始碼文本和行號輸出|
|**`"//&T+".*`**|`Opt_T=1`|啟動`Token Listing`(預設)|
|**`"//&T-".*`**|`Opt_T=0`|關閉`Token Listing`|

___
### 錯誤處理(Error Handling)
* 若沒有任何`Pattern`可以對應輸入的文本，便須輸出錯誤訊息。
    > 包含行號與錯誤文字開頭。
* 在`lex rule`的最後加入以下代碼，以捕捉所有未被`match`的字元(不含`\n`)。 
```cpp=
.   {
      /* error */
      printf("Error at line %d: bad character \"%s\"\n", linenum, yytext );
      exit(-1);
    }
```
___
### 結論(Conclusion)
* 透過使用`Regular Expression`以及`lex`，我們可以簡單的將輸入文本的代碼轉化成一個個的`Token`。
* 在往後可以將這些`Token`傳遞至`Parser`中進行語彙分析，使`Compiler`更趨完成。
