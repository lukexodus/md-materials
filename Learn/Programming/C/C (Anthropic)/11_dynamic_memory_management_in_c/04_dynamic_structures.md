## Dynamic Structures


Dynamic structures enable creation of complex data structures with variable size and interconnected elements at runtime.

**Dynamic Linked List:**

```c
typedef struct Node {
    int data;
    struct Node *next;
} Node;

typedef struct {
    Node *head;
    Node *tail;
    size_t size;
} LinkedList;

LinkedList* create_list() {
    LinkedList *list = (LinkedList*)malloc(sizeof(LinkedList));
    if (!list) return NULL;
    
    list->head = NULL;
    list->tail = NULL;
    list->size = 0;
    return list;
}

int insert_front(LinkedList *list, int value) {
    if (!list) return 0;
    
    Node *new_node = (Node*)malloc(sizeof(Node));
    if (!new_node) return 0;
    
    new_node->data = value;
    new_node->next = list->head;
    list->head = new_node;
    
    if (list->size == 0) {
        list->tail = new_node;
    }
    
    list->size++;
    return 1;
}
```

**Dynamic Binary Tree:**

```c
typedef struct TreeNode {
    int data;
    struct TreeNode *left;
    struct TreeNode *right;
} TreeNode;

TreeNode* create_node(int value) {
    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));
    if (!node) return NULL;
    
    node->data = value;
    node->left = NULL;
    node->right = NULL;
    return node;
}

TreeNode* insert_bst(TreeNode *root, int value) {
    if (root == NULL) {
        return create_node(value);
    }
    
    if (value < root->data) {
        root->left = insert_bst(root->left, value);
    } else if (value > root->data) {
        root->right = insert_bst(root->right, value);
    }
    
    return root;
}

void destroy_tree(TreeNode *root) {
    if (root) {
        destroy_tree(root->left);
        destroy_tree(root->right);
        free(root);
    }
}
```

**Dynamic Hash Table:**

```c
#define TABLE_SIZE 100

typedef struct HashEntry {
    char *key;
    int value;
    struct HashEntry *next;  // For collision handling
} HashEntry;

typedef struct {
    HashEntry **buckets;
    size_t size;
    size_t count;
} HashTable;

HashTable* create_hash_table() {
    HashTable *table = (HashTable*)malloc(sizeof(HashTable));
    if (!table) return NULL;
    
    table->buckets = (HashEntry**)calloc(TABLE_SIZE, sizeof(HashEntry*));
    if (!table->buckets) {
        free(table);
        return NULL;
    }
    
    table->size = TABLE_SIZE;
    table->count = 0;
    return table;
}

unsigned int hash_function(const char *key) {
    unsigned int hash = 0;
    while (*key) {
        hash = hash * 31 + *key++;
    }
    return hash % TABLE_SIZE;
}
```

**Dynamic String Buffer:**

```c
typedef struct {
    char *data;
    size_t length;
    size_t capacity;
} StringBuffer;

StringBuffer* create_buffer(size_t initial_capacity) {
    StringBuffer *buffer = (StringBuffer*)malloc(sizeof(StringBuffer));
    if (!buffer) return NULL;
    
    buffer->data = (char*)malloc(initial_capacity);
    if (!buffer->data) {
        free(buffer);
        return NULL;
    }
    
    buffer->data[0] = '\0';
    buffer->length = 0;
    buffer->capacity = initial_capacity;
    return buffer;
}

int append_string(StringBuffer *buffer, const char *str) {
    if (!buffer || !str) return 0;
    
    size_t str_len = strlen(str);
    size_t required_capacity = buffer->length + str_len + 1;
    
    if (required_capacity > buffer->capacity) {
        size_t new_capacity = required_capacity * 2;
        char *temp = (char*)realloc(buffer->data, new_capacity);
        if (!temp) return 0;
        
        buffer->data = temp;
        buffer->capacity = new_capacity;
    }
    
    strcpy(buffer->data + buffer->length, str);
    buffer->length += str_len;
    return 1;
}
```

**Key Points:**

- Always validate pointers before dereferencing
- Implement proper cleanup functions for complex structures
- Consider recursive cleanup for tree-like structures
- Use defensive programming techniques to handle edge cases

