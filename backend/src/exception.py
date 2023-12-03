class JsonReadException(Exception):
    """
    Invoked when JSON KeyError exception ocurrs.
    """
    def __init__(self, message="An error ocurred in reading JSON."):
        self.message = message
        super().__init__(self.message)


class PlainIdResponseException(Exception):
    """
    Invoked when PlantId API reponse code is different than 200.
    """
    def __init__(self, message="An error ocurred in PlantId response."):
        self.message = message
        super().__init__(self.message)


class IsNotPlantException(Exception):
    """
    Invoked when PlantId does not identify object as a plant.
    """
    def __init__(self, message="Photo does not represent a plant."):
        self.message = message
        super().__init__(self.message)
