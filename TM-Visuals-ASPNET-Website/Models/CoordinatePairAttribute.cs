using System.ComponentModel.DataAnnotations;

namespace TMVisualsWebApp.Models
{
    /// <summary>
    /// Validates Booking.Latitude and Booking.Longitude together. Apply it to Latitude only.
    /// Coordinates are optional, but if either one is supplied then both must
    /// be, and together they must be a real position. Errors are reported on
    /// Location, the field the user can actually see.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property)]
    public sealed class CoordinatePairAttribute : ValidationAttribute
    {
        /// <summary>
        /// Reusable check (e.g. for the reverse-geocode endpoint):
        /// finite numbers, within range, and not the (0, 0) "null island" default.
        /// </summary>
        public static bool IsValidPair(double latitude, double longitude) =>
            double.IsFinite(latitude) &&
            double.IsFinite(longitude) &&
            latitude is >= -90 and <= 90 &&
            longitude is >= -180 and <= 180 &&
            !(latitude == 0 && longitude == 0);

        protected override ValidationResult? IsValid(
            object? value, ValidationContext validationContext)
        {
            if (validationContext.ObjectInstance is not Booking booking)
            {
                return ValidationResult.Success;
            }

            var latitude = booking.Latitude;
            var longitude = booking.Longitude;

            // Neither supplied: nothing to check.
            if (latitude is null && longitude is null)
            {
                return ValidationResult.Success;
            }

            // Only one supplied: a half pair is meaningless.
            if (latitude is null || longitude is null)
            {
                return Fail(
                    "Please select the location again so that both coordinates are set.");
            }

            var lat = latitude.Value;
            var lng = longitude.Value;

            // NaN and Infinity can be bound from text such as "NaN", so check them first.
            if (!double.IsFinite(lat) || !double.IsFinite(lng))
            {
                return Fail("The selected location has invalid coordinates.");
            }

            if (lat is < -90 or > 90)
            {
                return Fail("The selected location has an invalid latitude.");
            }

            if (lng is < -180 or > 180)
            {
                return Fail("The selected location has an invalid longitude.");
            }

            if (lat == 0 && lng == 0)
            {
                return Fail("The selected location has invalid coordinates.");
            }

            return ValidationResult.Success;
        }

        private static ValidationResult Fail(string message) =>
            new(message, new[] { nameof(Booking.Location) });
    }
}