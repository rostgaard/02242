import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import output.TheLangLexer;
import output.TheLangParser;
import syntaxtree.Program;

public class Main {

	public static void printTree(CommonTree t, int indent) {
		if (t != null) {
			StringBuffer sb = new StringBuffer(indent);

			if (t.getParent() == null) {
				System.out.println(sb.toString() + 
						t.getClass().toString());
			}
			for (int i = 0; i < indent; i++) {
				sb = sb.append("   ");
			}
			for (int i = 0; i < t.getChildCount(); i++) {
				System.out.println(sb.toString() + t.getChild(i).toString());
				printTree((CommonTree) t.getChild(i), indent + 1);
			}
		}
	}

	public static void main(String args[]) throws Exception {
		String inputfile = args[0];
		System.out.println("input file: " + inputfile);
		TheLangLexer lex = new TheLangLexer(new ANTLRFileStream(inputfile));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		TheLangParser parser = new TheLangParser(tokens);

		try {
			TheLangParser.program_return parserResult = parser.program();
			if (parserResult != null) {
				Program tree = parserResult.value;
				System.out.println(tree.toString());
//				printTree(tree,0);
			}
		} catch (RecognitionException e) {
			e.printStackTrace();
		}
	}
}
