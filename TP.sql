USE [master]
GO
/****** Object:  Database [Personnel]    Script Date: 08/01/2025 16:51:35 ******/
CREATE DATABASE [Personnel]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Personnel', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Personnel.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Personnel_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Personnel_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Personnel] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Personnel].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Personnel] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Personnel] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Personnel] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Personnel] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Personnel] SET ARITHABORT OFF 
GO
ALTER DATABASE [Personnel] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Personnel] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Personnel] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Personnel] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Personnel] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Personnel] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Personnel] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Personnel] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Personnel] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Personnel] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Personnel] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Personnel] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Personnel] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Personnel] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Personnel] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Personnel] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Personnel] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Personnel] SET RECOVERY FULL 
GO
ALTER DATABASE [Personnel] SET  MULTI_USER 
GO
ALTER DATABASE [Personnel] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Personnel] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Personnel] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Personnel] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Personnel] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Personnel] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Personnel', N'ON'
GO
ALTER DATABASE [Personnel] SET QUERY_STORE = ON
GO
ALTER DATABASE [Personnel] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Personnel]
GO
/****** Object:  Table [dbo].[employes]    Script Date: 08/01/2025 16:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employes](
	[code_employe] [int] IDENTITY(1,1) NOT NULL,
	[nom_employe] [varchar](20) NOT NULL,
	[code_job] [varchar](4) NOT NULL,
	[niveau] [varchar](4) NOT NULL,
	[titre] [varchar](30) NOT NULL,
	[sexe] [varchar](1) NOT NULL,
	[date_naissance] [date] NOT NULL,
	[salaire] [decimal](7, 2) NOT NULL,
	[code_unite] [varchar](4) NOT NULL,
	[code_qualification] [varchar](4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[code_employe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EMPSQUAL]    Script Date: 08/01/2025 16:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMPSQUAL](
	[code_employe] [int] NOT NULL,
	[code_qualification] [varchar](4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[code_employe] ASC,
	[code_qualification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postes]    Script Date: 08/01/2025 16:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postes](
	[code_qualification] [varchar](4) NOT NULL,
	[code_unite] [varchar](4) NOT NULL,
	[nombre] [int] NOT NULL,
	[budget_poste] [decimal](7, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[code_qualification] ASC,
	[code_unite] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[qualifs]    Script Date: 08/01/2025 16:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[qualifs](
	[code_qualification] [varchar](4) NOT NULL,
	[libelle_qualification] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[code_qualification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[unites]    Script Date: 08/01/2025 16:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[unites](
	[code_unite] [varchar](4) NOT NULL,
	[nom_unite] [varchar](40) NOT NULL,
	[budget] [decimal](7, 0) NOT NULL,
	[unite_mere] [varchar](4) NULL,
PRIMARY KEY CLUSTERED 
(
	[code_unite] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [nom_idx]    Script Date: 08/01/2025 16:51:36 ******/
CREATE NONCLUSTERED INDEX [nom_idx] ON [dbo].[employes]
(
	[nom_employe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[employes]  WITH CHECK ADD FOREIGN KEY([code_qualification])
REFERENCES [dbo].[qualifs] ([code_qualification])
GO
ALTER TABLE [dbo].[employes]  WITH CHECK ADD FOREIGN KEY([code_unite])
REFERENCES [dbo].[unites] ([code_unite])
GO
ALTER TABLE [dbo].[EMPSQUAL]  WITH CHECK ADD FOREIGN KEY([code_employe])
REFERENCES [dbo].[employes] ([code_employe])
GO
ALTER TABLE [dbo].[EMPSQUAL]  WITH CHECK ADD FOREIGN KEY([code_qualification])
REFERENCES [dbo].[qualifs] ([code_qualification])
GO
ALTER TABLE [dbo].[Postes]  WITH CHECK ADD FOREIGN KEY([code_qualification])
REFERENCES [dbo].[qualifs] ([code_qualification])
GO
ALTER TABLE [dbo].[Postes]  WITH CHECK ADD FOREIGN KEY([code_unite])
REFERENCES [dbo].[unites] ([code_unite])
GO
ALTER TABLE [dbo].[unites]  WITH CHECK ADD FOREIGN KEY([unite_mere])
REFERENCES [dbo].[unites] ([code_unite])
GO
ALTER TABLE [dbo].[employes]  WITH CHECK ADD  CONSTRAINT [CHK_sexe] CHECK  (([sexe]='M' OR [sexe]='F'))
GO
ALTER TABLE [dbo].[employes] CHECK CONSTRAINT [CHK_sexe]
GO
ALTER TABLE [dbo].[Postes]  WITH CHECK ADD  CONSTRAINT [CHK_budget] CHECK  (([budget_poste]>(0)))
GO
ALTER TABLE [dbo].[Postes] CHECK CONSTRAINT [CHK_budget]
GO
ALTER TABLE [dbo].[Postes]  WITH CHECK ADD  CONSTRAINT [CHK_nombre] CHECK  (([nombre]<=(100) AND [nombre]>=(1)))
GO
ALTER TABLE [dbo].[Postes] CHECK CONSTRAINT [CHK_nombre]
GO
USE [master]
GO
ALTER DATABASE [Personnel] SET  READ_WRITE 
GO
