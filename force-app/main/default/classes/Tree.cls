public class Tree {
    public abstract class Node {
        public Node parent;
        public List<Node> children;
        public Node addChild(Node child) {
            child.parent = this;
            if(this.children == null) {
                this.children = new List<Node>();
            }
            this.children.add(child);
            return this;
        }
    }
}