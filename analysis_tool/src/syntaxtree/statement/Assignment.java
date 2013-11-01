package syntaxtree.statement;

import syntaxtree.expression.Variable;
import syntaxtree.expression.Expression;

/**
 * Data representation for assignments (variables only)
 *
 */
public class Assignment extends Statement {

	private Variable id;
	private Expression expr;
	
	public Assignment(Variable id, Expression expr){
		this.id = id;
		this.expr = expr;
	}
}