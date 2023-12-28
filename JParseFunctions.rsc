:do {/system script add owner=admin name=JParseFunctions} on-error={};
/system script set owner=admin JParseFunctions source="# -------------------------------- JParseFunctions -----------------------------------------\
    ----------\r\
    \n# ------------------------------- fJParsePrint ----------------------------------------------------------------\r\
    \n:global fJParsePrint\r\
    \n:if (!any \$fJParsePrint) do={ :global fJParsePrint do={\r\
    \n  :global JParseOut\r\
    \n  :local TempPath\r\
    \n  :global fJParsePrint\r\
    \n\r\
    \n  :if ([:len \$1] = 0) do={\r\
    \n    :set \$1 \"\\\$JParseOut\"\r\
    \n    :set \$2 \$JParseOut\r\
    \n   }\r\
    \n   \r\
    \n  :foreach k,v in=\$2 do={\r\
    \n    :if ([:typeof \$k] = \"str\") do={\r\
    \n      :set k \"\\\"\$k\\\"\"\r\
    \n    }\r\
    \n    :set TempPath (\$1. \"->\" . \$k)\r\
    \n    :if ([:typeof \$v] = \"array\") do={\r\
    \n      :if ([:len \$v] > 0) do={\r\
    \n        \$fJParsePrint \$TempPath \$v\r\
    \n      } else={\r\
    \n        :put \"\$TempPath = [] (\$[:typeof \$v])\"\r\
    \n      }\r\
    \n    } else={\r\
    \n        :put \"\$TempPath = \$v (\$[:typeof \$v])\"\r\
    \n    }\r\
    \n  }\r\
    \n}}\r\
    \n# ------------------------------- fJParsePrintVar ----------------------------------------------------------------\r\
    \n:global fJParsePrintVar\r\
    \n:if (!any \$fJParsePrintVar) do={ :global fJParsePrintVar do={\r\
    \n  :global JParseOut\r\
    \n  :local TempPath\r\
    \n  :global fJParsePrintVar\r\
    \n  :local fJParsePrintRet \"\"\r\
    \n\r\
    \n  :if ([:len \$1] = 0) do={\r\
    \n    :set \$1 \"\\\$JParseOut\"\r\
    \n    :set \$2 \$JParseOut\r\
    \n   }\r\
    \n   \r\
    \n  :foreach k,v in=\$2 do={\r\
    \n    :if ([:typeof \$k] = \"str\") do={\r\
    \n      :set k \"\\\"\$k\\\"\"\r\
    \n    }\r\
    \n    :set TempPath (\$1. \"->\" . \$k)\r\
    \n    :if (\$fJParsePrintRet != \"\") do={\r\
    \n      :set fJParsePrintRet (\$fJParsePrintRet . \"\\r\\n\")\r\
    \n    }    \r\
    \n    :if ([:typeof \$v] = \"array\") do={\r\
    \n      :if ([:len \$v] > 0) do={\r\
    \n        :set fJParsePrintRet (\$fJParsePrintRet . [\$fJParsePrintVar \$TempPath \$v])\r\
    \n      } else={\r\
    \n        :set fJParsePrintRet (\$fJParsePrintRet . \"\$TempPath = [] (\$[:typeof \$v])\")\r\
    \n      }\r\
    \n    } else={\r\
    \n        :set fJParsePrintRet (\$fJParsePrintRet . \"\$TempPath = \$v (\$[:typeof \$v])\")\r\
    \n    }\r\
    \n  }\r\
    \n  :return \$fJParsePrintRet\r\
    \n}}\r\
    \n# ------------------------------- fJSkipWhitespace ----------------------------------------------------------------\r\
    \n:global fJSkipWhitespace\r\
    \n:if (!any \$fJSkipWhitespace) do={ :global fJSkipWhitespace do={\r\
    \n  :global Jpos\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :while (\$Jpos < [:len \$JSONIn] and ([:pick \$JSONIn \$Jpos] ~ \"[ \\r\\n\\t]\")) do={\r\
    \n    :set Jpos (\$Jpos + 1)\r\
    \n  }\r\
    \n  :if (\$Jdebug) do={:put \"fJSkipWhitespace: Jpos=\$Jpos Char=\$[:pick \$JSONIn \$Jpos]\"}\r\
    \n}}\r\
    \n# -------------------------------- fJParse ---------------------------------------------------------------\r\
    \n:global fJParse\r\
    \n:if (!any \$fJParse) do={ :global fJParse do={\r\
    \n  :global Jpos\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :global fJSkipWhitespace\r\
    \n  :local Char\r\
    \n\r\
    \n  :if (!\$1) do={\r\
    \n    :set Jpos 0\r\
    \n   }\r\
    \n  \r\
    \n  \$fJSkipWhitespace\r\
    \n  :set Char [:pick \$JSONIn \$Jpos]\r\
    \n  :if (\$Jdebug) do={:put \"fJParse: Jpos=\$Jpos Char=\$Char\"}\r\
    \n  :if (\$Char=\"{\") do={\r\
    \n    :set Jpos (\$Jpos + 1)\r\
    \n    :global fJParseObject\r\
    \n    :return [\$fJParseObject]\r\
    \n  } else={\r\
    \n    :if (\$Char=\"[\") do={\r\
    \n      :set Jpos (\$Jpos + 1)\r\
    \n      :global fJParseArray\r\
    \n      :return [\$fJParseArray]\r\
    \n    } else={\r\
    \n      :if (\$Char=\"\\\"\") do={\r\
    \n        :set Jpos (\$Jpos + 1)\r\
    \n        :global fJParseString\r\
    \n        :return [\$fJParseString]\r\
    \n      } else={\r\
    \n#        :if ([:pick \$JSONIn \$Jpos (\$Jpos+2)]~\"^-\\\?[0-9]\") do={\r\
    \n        :if (\$Char~\"[eE0-9.+-]\") do={\r\
    \n          :global fJParseNumber\r\
    \n          :return [\$fJParseNumber]\r\
    \n        } else={\r\
    \n\r\
    \n          :if (\$Char=\"n\" and [:pick \$JSONIn \$Jpos (\$Jpos+4)]=\"null\") do={\r\
    \n            :set Jpos (\$Jpos + 4)\r\
    \n            :return []\r\
    \n          } else={\r\
    \n            :if (\$Char=\"t\" and [:pick \$JSONIn \$Jpos (\$Jpos+4)]=\"true\") do={\r\
    \n              :set Jpos (\$Jpos + 4)\r\
    \n              :return true\r\
    \n            } else={\r\
    \n              :if (\$Char=\"f\" and [:pick \$JSONIn \$Jpos (\$Jpos+5)]=\"false\") do={\r\
    \n                :set Jpos (\$Jpos + 5)\r\
    \n                :return false\r\
    \n              } else={\r\
    \n                :put \"Err.Raise 8732. No JSON object could be fJParseed\"\r\
    \n                :set Jpos (\$Jpos + 1)\r\
    \n                :return []\r\
    \n              }\r\
    \n            }\r\
    \n          }\r\
    \n        }\r\
    \n      }\r\
    \n    }\r\
    \n  }\r\
    \n}}\r\
    \n\r\
    \n#-------------------------------- fJParseString ---------------------------------------------------------------\r\
    \n:global fJParseString\r\
    \n:if (!any \$fJParseString) do={ :global fJParseString do={\r\
    \n  :global Jpos\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :global fUnicodeToUTF8\r\
    \n  :local Char\r\
    \n  :local StartIdx\r\
    \n  :local Char2\r\
    \n  :local TempString \"\"\r\
    \n  :local UTFCode\r\
    \n  :local Unicode\r\
    \n\r\
    \n  :set StartIdx \$Jpos\r\
    \n  :set Char [:pick \$JSONIn \$Jpos]\r\
    \n  :if (\$Jdebug) do={:put \"fJParseString: Jpos=\$Jpos Char=\$Char\"}\r\
    \n  :while (\$Jpos < [:len \$JSONIn] and \$Char != \"\\\"\") do={\r\
    \n    :if (\$Char=\"\\\\\") do={\r\
    \n      :set Char2 [:pick \$JSONIn (\$Jpos + 1)]\r\
    \n      :if (\$Char2 = \"u\") do={\r\
    \n        :set UTFCode [:tonum \"0x\$[:pick \$JSONIn (\$Jpos+2) (\$Jpos+6)]\"]\r\
    \n        :if (\$UTFCode>=0xD800 and \$UTFCode<=0xDFFF) do={\r\
    \n# Surrogate pair\r\
    \n          :set Unicode  ((\$UTFCode & 0x3FF) << 10)\r\
    \n          :set UTFCode [:tonum \"0x\$[:pick \$JSONIn (\$Jpos+8) (\$Jpos+12)]\"]\r\
    \n          :set Unicode (\$Unicode | (\$UTFCode & 0x3FF) | 0x10000)\r\
    \n          :set TempString (\$TempString . [:pick \$JSONIn \$StartIdx \$Jpos] . [\$fUnicodeToUTF8 \$Unicode])         \r\
    \n          :set Jpos (\$Jpos + 12)\r\
    \n        } else= {\r\
    \n# Basic Multilingual Plane (BMP)\r\
    \n          :set Unicode \$UTFCode\r\
    \n          :set TempString (\$TempString . [:pick \$JSONIn \$StartIdx \$Jpos] . [\$fUnicodeToUTF8 \$Unicode])\r\
    \n          :set Jpos (\$Jpos + 6)\r\
    \n        }\r\
    \n        :set StartIdx \$Jpos\r\
    \n        :if (\$Jdebug) do={:put \"fJParseString Unicode: \$Unicode\"}\r\
    \n      } else={\r\
    \n        :if (\$Char2 ~ \"[\\\\bfnrt\\\"]\") do={\r\
    \n          :if (\$Jdebug) do={:put \"fJParseString escape: Char+Char2 \$Char\$Char2\"}\r\
    \n          :set TempString (\$TempString . [:pick \$JSONIn \$StartIdx \$Jpos] . [[:parse \"(\\\"\\\\\$Char2\\\")\"]])\r\
    \n          :set Jpos (\$Jpos + 2)\r\
    \n          :set StartIdx \$Jpos\r\
    \n        } else={\r\
    \n          :if (\$Char2 = \"/\") do={\r\
    \n            :if (\$Jdebug) do={:put \"fJParseString /: Char+Char2 \$Char\$Char2\"}\r\
    \n            :set TempString (\$TempString . [:pick \$JSONIn \$StartIdx \$Jpos] . \"/\")\r\
    \n            :set Jpos (\$Jpos + 2)\r\
    \n            :set StartIdx \$Jpos\r\
    \n          } else={\r\
    \n            :put \"Err.Raise 8732. Invalid escape\"\r\
    \n            :set Jpos (\$Jpos + 2)\r\
    \n          }\r\
    \n        }\r\
    \n      }\r\
    \n    } else={\r\
    \n      :set Jpos (\$Jpos + 1)\r\
    \n    }\r\
    \n    :set Char [:pick \$JSONIn \$Jpos]\r\
    \n  }\r\
    \n  :set TempString (\$TempString . [:pick \$JSONIn \$StartIdx \$Jpos])\r\
    \n  :set Jpos (\$Jpos + 1)\r\
    \n  :if (\$Jdebug) do={:put \"fJParseString: \$TempString\"}\r\
    \n  :return \$TempString\r\
    \n}}\r\
    \n\r\
    \n#-------------------------------- fJParseNumber ---------------------------------------------------------------\r\
    \n:global fJParseNumber\r\
    \n:if (!any \$fJParseNumber) do={ :global fJParseNumber do={\r\
    \n  :global Jpos\r\
    \n  :local StartIdx\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :local NumberString\r\
    \n  :local Number\r\
    \n\r\
    \n  :set StartIdx \$Jpos   \r\
    \n  :set Jpos (\$Jpos + 1)\r\
    \n  :while (\$Jpos < [:len \$JSONIn] and [:pick \$JSONIn \$Jpos]~\"[eE0-9.+-]\") do={\r\
    \n    :set Jpos (\$Jpos + 1)\r\
    \n  }\r\
    \n  :set NumberString [:pick \$JSONIn \$StartIdx \$Jpos]\r\
    \n  :set Number [:tonum \$NumberString] \r\
    \n  :if ([:typeof \$Number] = \"num\") do={\r\
    \n    :if (\$Jdebug) do={:put \"fJParseNumber: StartIdx=\$StartIdx Jpos=\$Jpos \$Number (\$[:typeof \$Number])\"}\r\
    \n    :return \$Number\r\
    \n  } else={\r\
    \n    :if (\$Jdebug) do={:put \"fJParseNumber: StartIdx=\$StartIdx Jpos=\$Jpos \$NumberString (\$[:typeof \$NumberString])\"}\r\
    \n    :return \$NumberString\r\
    \n  }\r\
    \n}}\r\
    \n\r\
    \n#-------------------------------- fJParseArray ---------------------------------------------------------------\r\
    \n:global fJParseArray\r\
    \n:if (!any \$fJParseArray) do={ :global fJParseArray do={\r\
    \n  :global Jpos\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :global fJParse\r\
    \n  :global fJSkipWhitespace\r\
    \n  :local Value\r\
    \n  :local ParseArrayRet [:toarray \"\"]\r\
    \n  \r\
    \n  \$fJSkipWhitespace    \r\
    \n  :while (\$Jpos < [:len \$JSONIn] and [:pick \$JSONIn \$Jpos]!= \"]\") do={\r\
    \n    :set Value [\$fJParse true]\r\
    \n    :set (\$ParseArrayRet->([:len \$ParseArrayRet])) \$Value\r\
    \n    :if (\$Jdebug) do={:put \"fJParseArray: Value=\"; :put \$Value}\r\
    \n    \$fJSkipWhitespace\r\
    \n    :if ([:pick \$JSONIn \$Jpos] = \",\") do={\r\
    \n      :set Jpos (\$Jpos + 1)\r\
    \n      \$fJSkipWhitespace\r\
    \n    }\r\
    \n  }\r\
    \n  :set Jpos (\$Jpos + 1)\r\
    \n#  :if (\$Jdebug) do={:put \"ParseArrayRet: \"; :put \$ParseArrayRet}\r\
    \n  :return \$ParseArrayRet\r\
    \n}}\r\
    \n\r\
    \n# -------------------------------- fJParseObject ---------------------------------------------------------------\r\
    \n:global fJParseObject\r\
    \n:if (!any \$fJParseObject) do={ :global fJParseObject do={\r\
    \n  :global Jpos\r\
    \n  :global JSONIn\r\
    \n  :global Jdebug\r\
    \n  :global fJSkipWhitespace\r\
    \n  :global fJParseString\r\
    \n  :global fJParse\r\
    \n# Syntax :local ParseObjectRet ({}) don't work in recursive call, use [:toarray \"\"] for empty array!!!\r\
    \n  :local ParseObjectRet [:toarray \"\"]\r\
    \n  :local Key\r\
    \n  :local Value\r\
    \n  :local ExitDo false\r\
    \n  \r\
    \n  \$fJSkipWhitespace\r\
    \n  :while (\$Jpos < [:len \$JSONIn] and [:pick \$JSONIn \$Jpos]!=\"}\" and !\$ExitDo) do={\r\
    \n    :if ([:pick \$JSONIn \$Jpos]!=\"\\\"\") do={\r\
    \n      :put \"Err.Raise 8732. Expecting property name\"\r\
    \n      :set ExitDo true\r\
    \n    } else={\r\
    \n      :set Jpos (\$Jpos + 1)\r\
    \n      :set Key [\$fJParseString]\r\
    \n      \$fJSkipWhitespace\r\
    \n      :if ([:pick \$JSONIn \$Jpos] != \":\") do={\r\
    \n        :put \"Err.Raise 8732. Expecting : delimiter\"\r\
    \n        :set ExitDo true\r\
    \n      } else={\r\
    \n        :set Jpos (\$Jpos + 1)\r\
    \n        :set Value [\$fJParse true]\r\
    \n        :set (\$ParseObjectRet->\$Key) \$Value\r\
    \n        :if (\$Jdebug) do={:put \"fJParseObject: Key=\$Key Value=\"; :put \$Value}\r\
    \n        \$fJSkipWhitespace\r\
    \n        :if ([:pick \$JSONIn \$Jpos]=\",\") do={\r\
    \n          :set Jpos (\$Jpos + 1)\r\
    \n          \$fJSkipWhitespace\r\
    \n        }\r\
    \n      }\r\
    \n    }\r\
    \n  }\r\
    \n  :set Jpos (\$Jpos + 1)\r\
    \n#  :if (\$Jdebug) do={:put \"ParseObjectRet: \"; :put \$ParseObjectRet}\r\
    \n  :return \$ParseObjectRet\r\
    \n}}\r\
    \n\r\
    \n# ------------------- fByteToEscapeChar ----------------------\r\
    \n:global fByteToEscapeChar\r\
    \n:if (!any \$fByteToEscapeChar) do={ :global fByteToEscapeChar do={\r\
    \n#  :set \$1 [:tonum \$1]\r\
    \n  :return [[:parse \"(\\\"\\\\\$[:pick \"0123456789ABCDEF\" ((\$1 >> 4) & 0xF)]\$[:pick \"0123456789ABCDEF\" (\$1 & 0xF)]\\\")\"]]\r\
    \n}}\r\
    \n\r\
    \n# ------------------- fUnicodeToUTF8----------------------\r\
    \n:global fUnicodeToUTF8\r\
    \n:if (!any \$fUnicodeToUTF8) do={ :global fUnicodeToUTF8 do={\r\
    \n  :global fByteToEscapeChar\r\
    \n#  :local Ubytes [:tonum \$1]\r\
    \n  :local Nbyte\r\
    \n  :local EscapeStr \"\"\r\
    \n\r\
    \n  :if (\$1 < 0x80) do={\r\
    \n    :set EscapeStr [\$fByteToEscapeChar \$1]\r\
    \n  } else={\r\
    \n    :if (\$1 < 0x800) do={\r\
    \n      :set Nbyte 2\r\
    \n    } else={  \r\
    \n      :if (\$1 < 0x10000) do={\r\
    \n        :set Nbyte 3\r\
    \n      } else={\r\
    \n        :if (\$1 < 0x20000) do={\r\
    \n          :set Nbyte 4\r\
    \n        } else={\r\
    \n          :if (\$1 < 0x4000000) do={\r\
    \n            :set Nbyte 5\r\
    \n          } else={\r\
    \n            :if (\$1 < 0x80000000) do={\r\
    \n              :set Nbyte 6\r\
    \n            }\r\
    \n          }\r\
    \n        }\r\
    \n      }\r\
    \n    }\r\
    \n    :for i from=2 to=\$Nbyte do={\r\
    \n      :set EscapeStr ([\$fByteToEscapeChar (\$1 & 0x3F | 0x80)] . \$EscapeStr)\r\
    \n      :set \$1 (\$1 >> 6)\r\
    \n    }\r\
    \n    :set EscapeStr ([\$fByteToEscapeChar (((0xFF00 >> \$Nbyte) & 0xFF) | \$1)] . \$EscapeStr)\r\
    \n  }\r\
    \n  :return \$EscapeStr\r\
    \n}}\r\
    \n\r\
    \n# ------------------- Load JSON from arg --------------------------------\r\
    \nglobal JSONLoads\r\
    \nif (!any \$JSONLoads) do={ global JSONLoads do={\r\
    \n    global JSONIn \$1\r\
    \n    global fJParse\r\
    \n    local ret [\$fJParse]\r\
    \n    set JSONIn\r\
    \n    global Jpos; set Jpos\r\
    \n    global Jdebug; if (!\$Jdebug) do={set Jdebug}\r\
    \n    return \$ret\r\
    \n}}\r\
    \n\r\
    \n# ------------------- Load JSON from file --------------------------------\r\
    \nglobal JSONLoad\r\
    \nif (!any \$JSONLoad) do={ global JSONLoad do={\r\
    \n    if ([len [/file find name=\$1]] > 0) do={\r\
    \n        global JSONLoads\r\
    \n        return [\$JSONLoads [/file get \$1 contents]]\r\
    \n    }\r\
    \n}}\r\
    \n\r\
    \n# ------------------- Unload JSON parser library ----------------------\r\
    \nglobal JSONUnload\r\
    \nif (!any \$JSONUnload) do={ global JSONUnload do={\r\
    \n    global JSONIn; set JSONIn\r\
    \n    global Jpos; set Jpos\r\
    \n    global Jdebug; set Jdebug\r\
    \n    global fByteToEscapeChar; set fByteToEscapeChar\r\
    \n    global fJParse; set fJParse\r\
    \n    global fJParseArray; set fJParseArray\r\
    \n    global fJParseNumber; set fJParseNumber\r\
    \n    global fJParseObject; set fJParseObject\r\
    \n    global fJParsePrint; set fJParsePrint\r\
    \n    global fJParsePrintVar; set fJParsePrintVar\r\
    \n    global fJParseString; set fJParseString\r\
    \n    global fJSkipWhitespace; set fJSkipWhitespace\r\
    \n    global fUnicodeToUTF8; set fUnicodeToUTF8\r\
    \n    global JSONLoads; set JSONLoads\r\
    \n    global JSONLoad; set JSONLoad\r\
    \n    global JSONUnload; set JSONUnload\r\
    \n}}\r\
    \n# ------------------- End JParseFunctions----------------------"