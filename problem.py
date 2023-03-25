from pydantic import BaseModel, Field
from pydantic.dataclasses import dataclass as pydataclass

class ItemData(BaseModel):
    name: str = Field(example="Something fun")


class ItemId(BaseModel):
    id: str = Field(description="identifier of item", example="xyz123")


class Item(ItemId, ItemData):
    pass


@pydataclass
class ItemList(BaseModel):
    has_more: bool
    members: list[Item]


if __name__ == "__main__":
    print("here is trouble")
