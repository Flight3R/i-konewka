from openai import OpenAI
from load_credentials import load_secret

flower_type_from_api = "Pilea peperomioides"
default_ml_per_watering = 250
default_nof_watering_days = 2


API_KEY = load_secret('OPENAI_API_KEY')


def get_flower_type_watering_details_from_openai(flower_type_name):
  """
  OpenAI does not return code other than 200.
  """
  client = OpenAI(api_key=API_KEY)

  message = f"Hello chat, please privide me two values in seperate by coma. First ml_per_watering and nof_watering_days. \
              First  ml_per_watering is how much mililiters of water {flower_type_name} need and second nof_days \
              how many times a week {flower_type_name} should be water. Size of flower is huge. \
              Minimum value is 100 militers and 1 day a week. Please give me only two integers. \
              Please do not give me commeent."

  completion = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[
      {"role": "system", "content": message},
    ]
  )
  openai_response = completion.choices[0].message.content.replace(" ","").split(",")
  flower_type_details_dict ={'name': flower_type_name}

  if int(openai_response[1]) >= 1 and int(openai_response[1]) <= 6 and int(openai_response[0]) >= 140 and int(openai_response[0]) <= 1000:
    flower_type_details_dict['ml_per_watering'] = openai_response[0]
    flower_type_details_dict['nof_watering_days'] = openai_response[1]
  else:
    flower_type_details_dict['ml_per_watering'] = default_ml_per_watering
    flower_type_details_dict['nof_watering_days'] = default_nof_watering_days
  return(flower_type_details_dict)
