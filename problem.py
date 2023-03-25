from pydantic import BaseModel, Field

class Thing(BaseModel):
    name: str = Field(example="Something fun")

if __name__ == "__main__":
    print("here is trouble")
