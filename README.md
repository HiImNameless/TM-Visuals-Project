# TM Visuals Photography/Videography and Client Management System

## Project Overview
This project is being developed as part of the ITC327W Work-Integrated Learning module at the Central University of Technology. It is the client-facing mobile component of the Photographer Website & Client Management Platform, built for TM Visuals (Photography and Videography), addressing real business needs around booking, portfolio visibility, and secure content delivery.


## Group Members
- S Lukhele
- M Bonga
- S Mbasa
- Z Mvimbi
- K Matsane
- KTJ Phatsoane
- MF Mulaudzi
- B Lombaard 

## Tech Stack
- Flutter - Mobile application
- ASP.NET - Web application
- Supabase - Authentication and Storage

## Stakeholder
TM Visuals — Photography and Film business, located in Jozi, represented by Tshedza Mulaudzi.

## Repository Structure
This repository contains the Flutter mobile application for the Photographer Website & Client Management Plartform.

## Current Project Stage
Phase 2 - System Design and Interface prototype design

## Supabase-managed content
The Flutter admin app manages services, client delivery links, and the public portfolio. The website's **My Work** page reads only `portfolio_item` and `portfolio_category`; private rows in `client_content` are never published there.

Configure the website's `Supabase:Url` and `Supabase:Key` settings with the project's URL and a publishable/anon key. Do not use a Supabase secret/service-role key. Public read policies must allow anonymous reads from the portfolio tables, and uploaded portfolio media must have a public URL for the website to display it.
