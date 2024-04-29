SELECT *
FROM Portfolio_Project.dbo.HousingData

-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio_Project.dbo.HousingData

UPDATE HousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingData
ADD SaleDateConverted Date

UPDATE HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate property address data

SELECT PropertyAddress
FROM Portfolio_Project.dbo.HousingData
WHERE PropertyAddress is NULL

SELECT *
FROM Portfolio_Project.dbo.HousingData
ORDER BY ParcelID

SELECT HouseA.ParcelID, HouseA.PropertyAddress, HouseB.ParcelID, HouseB.PropertyAddress, ISNULL(HouseA.PropertyAddress, HouseB.PropertyAddress)
FROM Portfolio_Project.dbo.HousingData HouseA
JOIN Portfolio_Project.dbo.HousingData HouseB
	ON HouseA.ParcelID = HouseB.ParcelID
	AND HouseA.[UniqueID ] <> HouseB.[UniqueID ]
WHERE HouseA.PropertyAddress is NULL

UPDATE HouseA
SET PropertyAddress = ISNULL(HouseA.PropertyAddress, HouseB.PropertyAddress)
FROM Portfolio_Project.dbo.HousingData HouseA
JOIN Portfolio_Project.dbo.HousingData HouseB
	ON HouseA.ParcelID = HouseB.ParcelID
	AND HouseA.[UniqueID ] <> HouseB.[UniqueID ]
WHERE HouseA.PropertyAddress is NULL


-- Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project.dbo.HousingData

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress nvarchar(255)

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE HousingData
ADD PropertySplitCity nvarchar(255)

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project.dbo.HousingData


SELECT OwnerAddress
FROM Portfolio_Project.dbo.HousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Portfolio_Project.dbo.HousingData

ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255)

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE HousingData
ADD OwnerSplitState nvarchar(255)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM Portfolio_Project.dbo.HousingData


-- Change Y and N to Yes and No in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.HousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio_Project.dbo.HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- Remove duplicates

WITH RoWNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Portfolio_Project.dbo.HousingData
)
SELECT *
FROM RoWNumCTE
WHERE row_num > 1


-- Delete unused columns

SELECT *
FROM Portfolio_Project.dbo.HousingData

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingData
DROP COLUMN SaleDate