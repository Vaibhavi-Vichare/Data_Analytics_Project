/* Cleaning data in SQL */

SELECT * 
FROM PortfolioProject.dbo.[NashvilleHousing ];

-- Populate property address data --

-- ParcelId is equal to PropertyAddress. But some rows are having PropertyAdress value as Null. So we need to populate the PropertyAddress 

SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Foolowing query returns the updated value of PropertyAddress by replacing NULL value 

SELECT Table1.ParcelID , Table1.PropertyAddress , Table2.ParcelID , Table2.PropertyAddress, ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
FROM [NashvilleHousing ] as Table1
JOIN [NashvilleHousing ] as Table2
ON Table1.ParcelID = Table2.ParcelID
AND Table1.UniqueID <> Table2.UniqueID
WHERE Table1.PropertyAddress IS NULL;

-- Now we need to update the table

UPDATE Table1
SET PropertyAddress = ISNULL(Table1.PropertyAddress, Table2.PropertyAddress)
FROM [NashvilleHousing ] as Table1
JOIN [NashvilleHousing ] as Table2
ON Table1.ParcelID = Table2.ParcelID
AND Table1.UniqueID <> Table2.UniqueID
WHERE Table1.PropertyAddress IS NULL;

-- Breaking out OwnerAddress inot Individual Columns (Address, City, State)

SELECT OwnerAddress, PropertyAddress 
From [NashvilleHousing ];

/*
-- Different approach to break string on delimeter --

SELECT OwnerAddress , 
REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',','.'), 1)) AS Address,
REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',','.'), 2)) AS City,
REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',','.'), 3)) AS State
FROM [NashvilleHousing ];
*/

-- Using substring and charindex

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) - 1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress) ) AS Address
FROM [NashvilleHousing ];

ALTER TABLE NashvilleHousing
ADD PropertSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertSplitCity VARCHAR(255);

UPDATE [NashvilleHousing ]
SET PropertSplitAddress =  SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress) - 1 );

UPDATE [NashvilleHousing ]
SET  PropertSplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress));

-- Now we will split OwnerAddress -- 

SELECT OwnerAddress , 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM [NashvilleHousing ];

-- Adding columns into table

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Update the table -- 

UPDATE [NashvilleHousing ]
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

UPDATE [NashvilleHousing ]
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) ;

UPDATE [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) ;


SELECT *
FROM [NashvilleHousing ];

-- Change Y and N to Yes and No in "Sold as vacant" field --

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM [NashvilleHousing ];

UPDATE [NashvilleHousing ]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM [NashvilleHousing ];    


-- Remove duplicates -- 

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER 
(
    PARTITION BY ParcelId, PropertyAddress, SaleDate, SalePrice, LegalReference
    ORDER BY UniqueID
) AS row_num
FROM [NashvilleHousing ]
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

-- Delete unused column--

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

SELECT * 
FROM [NashvilleHousing ];