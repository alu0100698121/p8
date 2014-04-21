var assert = chai.assert;

suite('Analizador de PL0 Ampliado Usando PEG.js', function() {
    	test('Probando Statement', function() {
	   prueba = calculator.parse ("a=2;.")
	   assert.equal(prueba[0][0].left, "a")
	   assert.equal(prueba[0][0].type, "=")
	   assert.equal(prueba[0][0].right, "2")
	});
	
	test('Probando constantes', function() {
	    prueba = calculator.parse("const a=2;a = 1*9+4;.")
	    assert.equal(prueba[0][0][0].type, "CONST")
	    assert.equal(prueba[0][0][0].left, "a")
	    assert.equal(prueba[0][0][0].right, "2")
	});
	
	test('Probando variables', function() {
	    prueba = calculator.parse("var a;a = 1*9+4;.")
	    assert.equal(prueba[0][0][0].type, "VAR")
	    assert.equal(prueba[0][0][0].right, "a")
	});
	
	test('Probando Procedure', function() {
	    prueba = calculator.parse("procedure a(d) BEGIN a=12;END; a = 1*9+4;.")
	    assert.equal(prueba[0][0][0].type, "PROCEDURE")
	    assert.equal(prueba[0][0][0].id, "a")
	    
	    assert.equal(prueba[0][0][0].parameters[0].value, "0")
	    	    
	    assert.equal(prueba[0][0][0].block[0].type, "=")
	    assert.equal(prueba[0][0][0].block[0].right, "12")
	    assert.equal(prueba[0][0][0].block[0].left, "a")
      });

      
      test('Probando IF y condition', function() {
	    prueba = calculator.parse("IF a < 9 THEN b=9;.")
	       
	    assert.equal(prueba[0][0].type, "IF")
	    
	    assert.equal(prueba[0][0].condition.type, "<")
	    assert.equal(prueba[0][0].condition.left, "0")
   	    assert.equal(prueba[0][0].condition.right, "9")
	    
	    assert.equal(prueba[0][0].true_statement.type, "=")
	    assert.equal(prueba[0][0].true_statement.left, "b")
	    assert.equal(prueba[0][0].true_statement.right, "9")
     });
      
     test('Probando IF ELSE y condition', function() {
	    prueba = calculator.parse("IF a < 9 THEN b=9; ELSE b=5;.")
	    assert.equal(prueba[0][0].type, "IFELSE")
	    	    
	    assert.equal(prueba[0][0].condition.type, "<")
	    assert.equal(prueba[0][0].condition.left, "0")
   	    assert.equal(prueba[0][0].condition.right, "9")
	    
	    assert.equal(prueba[0][0].true_statement.type, "=")
	    assert.equal(prueba[0][0].true_statement.left, "b")
	    assert.equal(prueba[0][0].true_statement.right, "9")
	    
	    assert.equal(prueba[0][0].else_statement.type, "=")
	    assert.equal(prueba[0][0].else_statement.left, "b")
	    assert.equal(prueba[0][0].else_statement.right, "5")
     }); 
      
}); 