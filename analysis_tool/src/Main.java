
import analysis.IntervalLattice;
import analysis.ProgramSlicing;
import analysis.RDLattice;
import flowgraph.WorklistAlgorithm;
import flowgraph.datastructure.FlowSet;
import flowgraph.datastructure.NodeSet;
import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

import analysis.RDProgramState;
import analysis.SignsLattice;
import output.TheLangLexer;
import output.TheLangParser;
import syntaxtree.Program;
import syntaxtree.statement.Statement;
import utilities.Sequencer;

public class Main {

    public static void printTree(CommonTree t, int indent) {
        if (t != null) {
            StringBuffer sb = new StringBuffer(indent);

            if (t.getParent() == null) {
                System.out.println(sb.toString()
                        + t.getClass().toString());
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
        if (args.length < 1) {
            System.out.println("Please supply a file with source code as argument.");
            System.exit(1);
        }

        String inputfile = args[0];
        System.out.println("input file: " + inputfile);
        TheLangLexer lex = new TheLangLexer(new ANTLRFileStream(inputfile));
        CommonTokenStream tokens = new CommonTokenStream(lex);
        TheLangParser parser = new TheLangParser(tokens);

        try {
            TheLangParser.program_return parserResult = parser.program();
            if (parserResult != null) {
                Program program = parserResult.value;
                Sequencer seq = new Sequencer();

                // Intially set the labels.
                for (Statement s : program.getStmts()) {
                    s.setLabel(seq);
                }

                System.out.println("==== Program =====");
                System.out.println(program.getStmts().toStringWithLabel());
                System.out.println("==== End program =====");
                
                System.out.println("==== Labels =====");
                System.out.println(program.getStmts().lables());
                
                System.out.println("==== Reaching definitions =====");
                System.out.println(program.calculate(new RDLattice(program.getDecls())));
                
                //System.out.println("==== Program slice ====");
                //NodeSet programSlice = ProgramSlicing.execute(flows.get(2).getSource(), analysis);
                //ystem.out.println(programSlice);

                System.out.println("==== Signs analysis =====");
                System.out.println(program.calculate(new SignsLattice(program.getDecls())));
                
                System.out.println("==== Interval analysis =====");
                System.out.println(program.calculate(new IntervalLattice(program.getDecls())));

            }
        } catch (RecognitionException e) {
            e.printStackTrace();
        }
    }
}
