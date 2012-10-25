(function()
 
{
 
        // CommonJS
 
        typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;
 
 
 
        function Brush()
 
        {
 
                var keywords = ['Feature:', 'Background:', 'Scenario:', 'Scenario Outline:', 'Examples:'];
 
                var steps =     ' Given When Then And But';
 
                var regexList = [
 
                        { regex: SyntaxHighlighter.regexLib.singleLinePerlComments, css: 'comments' },  // one line comments
 
                        { regex: SyntaxHighlighter.regexLib.doubleQuotedString, css: 'string' },        // double quoted strings
 
                        { regex: SyntaxHighlighter.regexLib.singleQuotedString, css: 'string' },        // single quoted strings
 
                        { regex: /\b[0-9]+(\.[0-9]+)?\b/gm, css: 'string' },                            //numbers
 
                        { regex: /\|(?:.+)\|/gm, css: 'value'},                                         //tables
 
                        { regex: /<.+>/gm, css: 'variable'},                                            //varibles
 
                        { regex: /@[a-zA-z]+.*/gm, css: 'color2'},                                      //tags
 
                       { regex: new RegExp(this.getKeywords(steps), 'g'), css: 'constants' }           //steps
 
                        ];
 
 
 
              // var keywordsRegexList = [{regex: new RegExp(keyword,'g'), css: 'keyword'} for each (keyword in keywords)];
 
               var keywordsRegexList = [];
 
               for(var i = 0, len = keywords.length; i < len; i++ ){
 
                  keywordsRegexList.push({regex: new RegExp(keywords[i],'g'), css: 'keyword'});
 
               }
 
               this.regexList = regexList.concat(keywordsRegexList);
 
 
 
               this.forHtmlScript(SyntaxHighlighter.regexLib.aspScriptTags);
 
        };
 
 
 
        Brush.prototype = new SyntaxHighlighter.Highlighter();
 
        Brush.aliases   = ['cuke', 'cucumber'];
 
 
 
        SyntaxHighlighter.brushes.Cuke = Brush;
 
 
 
        // CommonJS
 
        typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
 
})();
