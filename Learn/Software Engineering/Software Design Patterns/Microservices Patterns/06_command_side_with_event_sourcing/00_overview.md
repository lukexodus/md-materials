## Overview


from dataclasses import dataclass
from datetime import datetime
from typing import List
from enum import Enum
import uuid

class OrderStatus(Enum):
    DRAFT = "DRAFT"
    PLACED = "PLACED"
    CANCELLED = "CANCELLED"
    DELIVERED = "DELIVERED"

