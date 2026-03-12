try:
    import chromadb
    client = chromadb.EphemeralClient()
    print("✅ Success: ChromaDB Rust bindings loaded perfectly!")
except Exception as e:
    print(f"❌ Still failing: {e}")