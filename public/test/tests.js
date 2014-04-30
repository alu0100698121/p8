var assert = chai.assert;

suite('Analizador de PL0 Ampliado Usando PEG.js', function() {
    	test('Probando Statement', function() {
	   prueba = calculator.parse ("var a; a=2;.")
	   assert.equal(prueba[0][1].left, "a")
	   assert.equal(prueba[0][1].type, "=")
	   assert.equal(prueba[0][1].right, "2")
	});
	
	test('Probando constantes', function() {
	    prueba = calculator.parse("const a=2; var t; t = 1*9+4;.")
// 	    assert.equal(prueba[0][0][0].type, "CONST")
// 	    assert.equal(prueba[0][0][0].left, "a")
// 	    assert.equal(prueba[0][0][0].right, "2")
	    assert.equal(prueba[0][0], "const")
	});
	
	test('Probando variables', function() {
	    prueba = calculator.parse("var a;a = 1*9+4;.")
	    assert.equal(prueba[0][0][0].type, "VAR")
	    assert.equal(prueba[0][0][0].right, "a")
	});
	
	test('Probando Procedure', function() {
	    prueba = calculator.parse("var a; procedure tutu(d) BEGIN var h; h=12;END; a = 1*9+4;.")
// 	    assert.equal(prueba[0][0][0].type, "PROCEDURE")
// 	    assert.equal(prueba[0][0][0].id, "a")
// 	    
// 	    assert.equal(prueba[0][0][0].parameters[0].value, "0")
// 	    	    
// 	    assert.equal(prueba[0][0][0].block[0].type, "=")
// 	    assert.equal(prueba[0][0][0].block[0].right, "12")
// 	    assert.equal(prueba[0][0][0].block[0].left, "a")
	    assert.equal(prueba[0][1][0].type, "PROCEDURE")
	    assert.equal(prueba[0][1][0].id, "tutu")
	    assert.equal(prueba[0][1][0].parameters[0].type, "PAR")
	    assert.equal(prueba[0][1][0].parameters[0].value, "d")
	    assert.equal(prueba[0][1][0].block[0][0].right, "h")
	    assert.equal(prueba[0][1][0].block[0][0].type, "VAR")
	    assert.equal(prueba[0][1][0].block[1].left, "h")
	    assert.equal(prueba[0][1][0].block[1].right, 12)
	    assert.equal(prueba[0][1][0].block[1].type, "=")
      });

      
      test('Probando IF y condition', function() {
	    prueba = calculator.parse("var a,b; IF a < 9 THEN b=9;.")
	       
	    assert.equal(prueba[0][1].type, "IF")
	    
	    assert.equal(prueba[0][0][0].type, "VAR")
   	    assert.equal(prueba[0][0][0].right, "a")
	    
	    assert.equal(prueba[0][1].condition.type, "<")
	    assert.equal(prueba[0][1].condition.left, 0)
	    assert.equal(prueba[0][1].condition.right, 9)
	    
	    assert.equal(prueba[0][1].true_statement.type, "=")
	    assert.equal(prueba[0][1].true_statement.left, "b")
	    assert.equal(prueba[0][1].true_statement.right, 9)
     });
      
     test('Probando IF ELSE y condition', function() {
	    prueba = calculator.parse("var a,b; IF a < 9 THEN b=9; ELSE b=5;.")
	    assert.equal(prueba[0][1].type, "IFELSE")
	    	    
	    assert.equal(prueba[0][0][0].type, "VAR")
    	    assert.equal(prueba[0][0][0].right, "a")
	    assert.equal(prueba[0][1].condition.left, 0)
	    assert.equal(prueba[0][1].condition.right, 9)
	    assert.equal(prueba[0][1].condition.type, "<")
	    assert.equal(prueba[0][1].true_statement.left, "b")
	    assert.equal(prueba[0][1].true_statement.right, 9)
	    assert.equal(prueba[0][1].true_statement.type, "=")
	    assert.equal(prueba[0][1].else_statement.left, "b")
	    assert.equal(prueba[0][1].else_statement.right, 5)
	    assert.equal(prueba[0][1].else_statement.type, "=")
     }); 
      
}); 