import { Body, Controller, Get, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Get()
  async checkPath() {
    return "You're at the right path, continue!";
  }

  // POST http://localhost:3000/auth/signup
  @Post('signup')
  async signUp(@Body() body: any) {
    return this.authService.signUp(body.email, body.password, body.role);
  }

  // POST http://localhost:3000/auth/login
  @Post('login')
  async login(@Body() body: any) {
    return this.authService.login(body.email, body.password);
  }

  // POST http://localhost:3000/auth/google
  @Post('google')
  async googleLogin(@Body() body: any) {
    return this.authService.googleLogin(body.idToken, body.role);
  }
}
