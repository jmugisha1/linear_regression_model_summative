from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, conint
import numpy as np
import pickle as pk
import os

# Ensure the model file exists
if not os.path.exists('model.pkl'):
    raise RuntimeError("Model file 'model.pkl' not found in the current directory.")

# Load the trained model
model = pk.load(open('model.pkl', 'rb'))

# Define the input data model using Pydantic
class SalaryPredictionInput(BaseModel):
    Age: conint(ge=18, le=65)
    Gender: conint(ge=0, le=1)
    EducationLevel: conint(ge=0, le=2)
    YearsOfExperience: conint(ge=0, le=50)

# Initialize FastAPI app
app = FastAPI()

# Add CORS middleware
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Welcome to the Salary Prediction API!"}

# Define the prediction endpoint
@app.post('/predict')
def predict(input_data: SalaryPredictionInput):
    try:
        input_array = np.array([[input_data.Age, input_data.Gender, input_data.EducationLevel, input_data.YearsOfExperience]])
        prediction = model.predict(input_array)
        return {"predicted_salary": float(prediction[0])}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Run the FastAPI app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)