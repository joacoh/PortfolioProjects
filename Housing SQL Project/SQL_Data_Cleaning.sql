SELECT * 
FROM PortfolioProject.dbo.housing

-- NEW FORMAT FOR SALESDATE

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.housing

ALTER TABLE PortfolioProject.dbo.housing
ALTER COLUMN SaleDate DATE

-- POPULATE PROPERTY ADDRESS DATA USING PARCELID

SELECT pri.ParcelID, pri.PropertyAddress, sec.ParcelID, sec.PropertyAddress, ISNULL(pri.PropertyAddress, sec.PropertyAddress)
FROM PortfolioProject.dbo.housing AS pri
JOIN PortfolioProject.dbo.housing AS sec
	ON pri.ParcelID = sec.ParcelID
	AND pri.[UniqueID ] <> sec.[UniqueID ]
WHERE pri.PropertyAddress IS NULL

UPDATE pri 
SET PropertyAddress = ISNULL(pri.PropertyAddress, sec.PropertyAddress)
FROM PortfolioProject.dbo.housing AS pri
JOIN PortfolioProject.dbo.housing AS sec
	ON pri.ParcelID = sec.ParcelID
	AND pri.[UniqueID ] <> sec.[UniqueID ]
WHERE pri.PropertyAddress IS NULL

-- BREAKING OUT ADDRESS COLUMN INTO STREET AND CITY

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.housing

ALTER TABLE PortfolioProject.dbo.housing
ADD PropertyStreet nvarchar(255)

UPDATE PortfolioProject.dbo.housing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.housing
ADD PropertyCity nvarchar(255)

UPDATE PortfolioProject.dbo.housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertyStreet, PropertyCity
FROM PortfolioProject.dbo.housing

-- SAME NOW FOR OWNER ADDRESS

SELECT OwnerAddress
FROM PortfolioProject.dbo.housing

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject.dbo.housing

ALTER TABLE PortfolioProject.dbo.housing
ADD OwnerStreet nvarchar(255)

ALTER TABLE PortfolioProject.dbo.housing
ADD OwnerCity nvarchar(255)

ALTER TABLE PortfolioProject.dbo.housing
ADD OwnerState nvarchar(255)

UPDATE PortfolioProject.dbo.housing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

UPDATE PortfolioProject.dbo.housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

UPDATE PortfolioProject.dbo.housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT OwnerAddress, OwnerStreet, OwnerCity, OwnerState
FROM PortfolioProject.dbo.housing

-- CHANGE Y AND N TO YES AND NO IN SOLD/VACANT FIELD

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.housing

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.housing

UPDATE PortfolioProject.dbo.housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num

From PortfolioProject.dbo.housing

)
DELETE
From RowNumCTE
Where row_num > 1

-- DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject.dbo.housing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

SELECT *
FROM PortfolioProject.dbo.housing