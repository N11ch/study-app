/*
 * Data transfer Object (we'll gonna transfer the data into the part)
 * */
export class UpdateProfileDTO {
  full_name?: string;
  username?: string;
  bio?: string;
  avatar_url?: string;
  /*
   * ONLY!!!! ["STUDENT"] AND ["TUTOR"]*/
  role?: string;
}
